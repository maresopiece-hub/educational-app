import 'package:flutter/material.dart';
import '../models/study_plan.dart';

class GeneratedPreviewScreen extends StatefulWidget {
  final List<StudyPlan> plans;
  const GeneratedPreviewScreen({super.key, required this.plans});

  @override
  State<GeneratedPreviewScreen> createState() => _GeneratedPreviewScreenState();
}

class _GeneratedPreviewScreenState extends State<GeneratedPreviewScreen> {
  int _index = 0;

  void _next() {
    if (_index < widget.plans.length - 1) setState(() => _index++);
  }

  void _prev() {
    if (_index > 0) setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plans[_index];
    return Scaffold(
      appBar: AppBar(
        title: Text(plan.topic),
        actions: [
          Center(child: Text('${_index + 1}/${widget.plans.length}')),
          const SizedBox(width: 12),
        ],
      ),
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
            if (plan.subtopics.isNotEmpty) ...[
              const Text('Subtopics', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...plan.subtopics.map((s) => ListTile(title: Text(s.title))),
              const SizedBox(height: 12),
            ],
            if (plan.flashcards.isNotEmpty) ...[
              const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...plan.flashcards.map((f) => ListTile(title: Text(f.front), subtitle: Text(f.back))),
            ],
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ElevatedButton(onPressed: _prev, child: const Text('Previous')),
              ElevatedButton(onPressed: _next, child: const Text('Next')),
            ])
          ]),
        ),
      ),
    );
  }
}
