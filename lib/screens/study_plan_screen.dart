import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_plan.dart';

class StudyPlanScreen extends StatelessWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<StudyPlan>('studyPlans');
    return Scaffold(
      appBar: AppBar(title: const Text('Study Plans')),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<StudyPlan> b, _) {
          if (b.isEmpty) return const Center(child: Text('No study plans found.'));
          return ListView.builder(
            itemCount: b.length,
            itemBuilder: (context, i) {
              final p = b.getAt(i)!;
              return ListTile(
                title: Text(p.topic),
                subtitle: Text('${p.subtopics.length} subtopics • ${p.flashcards.length} flashcards'),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(p.topic),
                    content: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.explanations.isNotEmpty) ...[
                            const Text('Explanations', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(p.explanations.join('\n\n')),
                            const SizedBox(height: 12),
                          ],
                          if (p.flashcards.isNotEmpty) ...[
                            const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...p.flashcards.map((f) => ListTile(title: Text(f.front), subtitle: Text(f.back))),
                          ],
                        ],
                      ),
                    ),
                    actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
