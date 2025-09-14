import 'package:flutter/material.dart';
import '../models/lesson_plan.dart';

class LessonPreview extends StatelessWidget {
  final LessonPlan plan;
  const LessonPreview({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(plan.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        ...plan.sections.take(5).map((s) => Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(s.title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(s.explanation),
                  const SizedBox(height: 6),
                  if (s.questions.isNotEmpty) Text('Sample question: ${s.questions.first.prompt}', style: const TextStyle(fontStyle: FontStyle.italic)),
                ]),
              ),
            ))
      ],
    );
  }
}
