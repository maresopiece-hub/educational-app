import 'package:flutter/material.dart';
import '../services/file_picker_service.dart';
import '../services/parser_service.dart';
import '../services/generator_service.dart';
import 'package:hive/hive.dart';
import '../models/study_plan.dart';
import 'study_plan_detail_screen.dart';
import 'generated_preview_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String _status = 'Idle';

  Future<void> _pickAndProcess() async {
    setState(() => _status = 'Picking...');
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(navigator.context);
    final picker = DefaultFilePickerService();
    final parser = DefaultParserService();
    final generator = DefaultGeneratorService();
    try {
      final picked = await picker.pickFile();
      if (picked == null) {
        setState(() => _status = 'No file selected');
        return;
      }

  // show progress (use AlertDialog to avoid context oddities on some Android versions)
  // Use determinate indicator to avoid pumpAndSettle hangs in widget tests
  // ignore: use_build_context_synchronously
  showDialog<void>(context: navigator.context, barrierDismissible: false, builder: (_) => const AlertDialog(content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator(value: 1.0)))));

      final text = await parser.extractTextFromBytes(picked.bytes);
      final plans = await generator.generateFromText(text);

      final box = Hive.box<StudyPlan>('studyPlans');
      int? firstIndex;
      for (final p in plans) {
        final idx = await box.add(p);
        firstIndex ??= idx;
      }

      // close progress
      try {
        navigator.pop();
      } catch (_) {}

      if (plans.isEmpty) {
        // Fallback: if parsing returned raw text, create a temporary StudyPlan to preview
        if (text.trim().isNotEmpty) {
          final fallback = StudyPlan(topic: 'Preview', explanations: [text.trim().split('\n').take(3).join('\n')]);
          if (!mounted) return;
          navigator.push(MaterialPageRoute(builder: (_) => GeneratedPreviewScreen(plans: [fallback])));
          return;
        }
        setState(() => _status = 'No study plans generated');
        messenger.showSnackBar(const SnackBar(content: Text('No study plans were generated from the file.')));
        return;
      }

      setState(() => _status = 'Imported ${plans.length} study plans');

      if (!mounted) return;
      if (plans.length > 1) {
        navigator.push(MaterialPageRoute(builder: (_) => GeneratedPreviewScreen(plans: plans)));
        return;
      }
      // single plan — show detail
      if (firstIndex != null) {
        final saved = box.getAt(firstIndex);
        if (saved != null) {
          navigator.push(MaterialPageRoute(builder: (_) => StudyPlanDetailScreen(plan: saved)));
          return;
        }
      }
      // fallback to preview of generated plans
      navigator.push(MaterialPageRoute(builder: (_) => GeneratedPreviewScreen(plans: plans)));
    } catch (e) {
      try { navigator.pop(); } catch (_) {}
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(onPressed: _pickAndProcess, child: const Text('Pick File')),
            const SizedBox(height: 16),
            Text('Status: $_status'),
          ],
        ),
      ),
    );
  }
}
