import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/study_plan.dart';

class StudyPlanDetailScreen extends StatefulWidget {
  final StudyPlan plan;
  const StudyPlanDetailScreen({super.key, required this.plan});

  @override
  State<StudyPlanDetailScreen> createState() => _StudyPlanDetailScreenState();
}

class _StudyPlanDetailScreenState extends State<StudyPlanDetailScreen> {
  late StudyPlan plan;

  @override
  void initState() {
    super.initState();
    plan = widget.plan;
  }

  Future<void> _editTitle() async {
    final controller = TextEditingController(text: plan.topic);
    final res = await showDialog<String?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit title'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save'))
        ],
      ),
    );
    if (res != null && res.trim().isNotEmpty) {
      setState(() {
        plan.topic = res.trim();
      });
      try {
        // try to save to Hive if backed by box
        await plan.save();
      } catch (_) {}
    }
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool?>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete study plan?'),
        content: const Text('This will remove the plan. You can undo.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete'))
        ],
      ),
    );
    if (ok != true) return;

    final box = Hive.box<StudyPlan>('studyPlans');
    final idx = box.values.toList().indexOf(plan);
    final backup = plan.toJson();
    if (idx >= 0) {
      await box.deleteAt(idx);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Study plan deleted'),
        action: SnackBarAction(label: 'Undo', onPressed: () async {
          final restored = StudyPlan.fromJson(backup);
          await box.add(restored);
        }),
      ));
      Navigator.pop(context);
    }
  }

  void _exportJson() {
    final json = plan.toJson();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export JSON'),
        content: SingleChildScrollView(child: Text(json.toString())),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(plan.topic), actions: [
        IconButton(onPressed: _exportJson, icon: const Icon(Icons.share)),
        IconButton(onPressed: _editTitle, icon: const Icon(Icons.edit)),
        IconButton(onPressed: _confirmDelete, icon: const Icon(Icons.delete)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(plan.topic, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (plan.explanations.isNotEmpty) ...[
              const Text('Explanations', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(plan.explanations.join('\n\n')),
              const SizedBox(height: 12),
            ],
            if (plan.flashcards.isNotEmpty) ...[
              const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...plan.flashcards.map((f) => ListTile(title: Text(f.front), subtitle: Text(f.back))),
            ]
          ]),
        ),
      ),
    );
  }
}
