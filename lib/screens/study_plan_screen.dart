import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/study_plan.dart';
import 'study_plan_detail_screen.dart';

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
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudyPlanDetailScreen(plan: p))),
              );
            },
          );
        },
      ),
    );
  }
}
