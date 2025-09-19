import 'package:flutter/material.dart';
import '../models/study_plan.dart';

class SubtopicDetailScreen extends StatefulWidget {
  final StudyPlan plan;
  final List<Subtopic> path; // path of nested subtopics (0 = top-level)
  const SubtopicDetailScreen({super.key, required this.plan, required this.path});

  @override
  State<SubtopicDetailScreen> createState() => _SubtopicDetailScreenState();
}

class _SubtopicDetailScreenState extends State<SubtopicDetailScreen> {
  late Subtopic current;

  @override
  void initState() {
    super.initState();
  current = widget.path.isEmpty ? Subtopic(title: widget.plan.topic) : widget.path.last;
  }

  Future<void> _addItem(String kind) async {
    final controller = TextEditingController();
    final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: Text('Add $kind'), content: TextField(controller: controller), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
    if (res == null || res.trim().isEmpty) return;
    setState(() {
      final v = res.trim();
      if (kind == 'explanation') current.explanations.add(v);
      if (kind == 'note') current.notes.add(v);
      if (kind == 'question') current.questions.add(Question(type: widget.plan.defaultQuestionType, prompt: v));
      if (kind == 'flashcard') current.flashcards.add(Flashcard(front: v, back: ''));
      if (kind == 'subtopic') {
        final depth = widget.path.length + 1; // adding one level
        if (depth >= 10) {
          if (mounted) showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Depth limit'), content: const Text('Subtopic depth limit (10) reached.'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
          return;
        }
        current.subtopics.add(Subtopic(title: v));
      }
    });
    try {
      await widget.plan.save();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(current.title)),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ExpansionTile(title: const Text('Explanations', style: TextStyle(fontWeight: FontWeight.bold)), children: current.explanations.map((e) => ListTile(title: Text(e))).toList()),
            const SizedBox(height: 12),
            ExpansionTile(title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)), children: current.notes.map((n) => ListTile(title: Text(n))).toList()),
            const SizedBox(height: 12),
            ExpansionTile(title: const Text('Questions', style: TextStyle(fontWeight: FontWeight.bold)), children: current.questions.map((q) => ListTile(title: Text(q.prompt))).toList()),
            const SizedBox(height: 12),
            ExpansionTile(title: const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)), children: current.flashcards.map((f) => ListTile(title: Text(f.front), subtitle: Text(f.back))).toList()),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Subtopics', style: const TextStyle(fontWeight: FontWeight.bold)), IconButton(onPressed: () => _addItem('subtopic'), icon: const Icon(Icons.add))]),
            const SizedBox(height: 8),
            ...current.subtopics.map((st) {
              return ListTile(
                title: Text(st.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final newPath = [...widget.path, st];
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => SubtopicDetailScreen(plan: widget.plan, path: newPath)));
                  setState(() {});
                },
              );
            }).toList(),
          ]),
        ),
      ),
    );
  }
}
