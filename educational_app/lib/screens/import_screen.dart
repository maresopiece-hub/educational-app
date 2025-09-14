import 'package:flutter/material.dart';
import '../services/file_service.dart';
import '../services/document_parser.dart';
import '../services/segmentation_service.dart';
import '../services/lesson_generator_service.dart';
import '../widgets/lesson_preview.dart';
import '../models/lesson_plan.dart';
import '../services/srs_service.dart';
import '../services/flashcard_db.dart';

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final _fileService = FileService();
  final _parser = DocumentParser();
  final _seg = SegmentationService();
  final _gen = LessonGeneratorService();
  final _srs = SrsService();
  String? _extracted;
  bool _busy = false;
  LessonPlan? _plan;

  Future<void> _saveAsDeck() async {
    if (_plan == null) return;
    final cards = _srs.generateFromLesson(_plan!);
    for (final c in cards) {
      await FlashcardDb.saveCard(c);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved deck to local storage')));
  }

  Future<void> _pickAndParse() async {
    setState(() => _busy = true);
    final path = await _fileService.pickAndSaveFile();
    if (path != null) {
      String text = '';
      if (path.toLowerCase().endsWith('.pdf')) {
        text = await _parser.extractPdfText(path);
      } else if (path.toLowerCase().endsWith('.pptx')) {
        text = await _parser.extractPptxText(path);
      }
      // Run segmentation and generate lesson plan
      final sections = _seg.splitIntoSections(text);
      final plan = _gen.generateFromSections(sections, title: 'Auto-generated plan');
      setState(() {
        _extracted = text;
        _plan = plan;
      });
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Document')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick PDF/PPTX'),
              onPressed: _busy ? null : _pickAndParse,
            ),
            const SizedBox(height: 12),
            if (_busy) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(_extracted ?? 'No document imported yet.'),
                    const SizedBox(height: 12),
                    if (_plan != null) ...[
                      const Divider(),
                      const Text('Generated lesson plan preview', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      LessonPreview(plan: _plan!),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(onPressed: _saveAsDeck, icon: const Icon(Icons.save), label: const Text('Save as deck'))
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
