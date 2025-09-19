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
            // Explanations section with add button
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Explanations', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: _addExplanation, icon: const Icon(Icons.add)),
            ]),
            if (plan.explanations.isEmpty)
              const Text('No explanations yet', style: TextStyle(color: Colors.grey))
            else ...[
              const SizedBox(height: 8),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex -= 1;
                  setState(() {
                    final item = plan.explanations.removeAt(oldIndex);
                    plan.explanations.insert(newIndex, item);
                  });
                  try { await plan.save(); } catch (_) {}
                },
                children: plan.explanations.asMap().entries.map((e) {
                  final idx = e.key;
                  final text = e.value;
                  return ListTile(
                    key: ValueKey('exp_$idx'),
                    title: Text(text),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                        final controller = TextEditingController(text: text);
                        final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit explanation'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save'))]));
                        if (res == null || res.trim().isEmpty) return;
                        setState(() => plan.explanations[idx] = res.trim());
                        try { await plan.save(); } catch (_) {}
                      }),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final removed = plan.explanations.removeAt(idx);
                        setState(() {});
                        try { await plan.save(); } catch (_) {}
                        if (!mounted) return;
                        messenger.showSnackBar(SnackBar(content: const Text('Explanation deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => plan.explanations.insert(idx, removed)); try { await plan.save(); } catch (_) {} })));
                      })
                    ]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Notes
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: _addNote, icon: const Icon(Icons.add)),
            ]),
            if (plan.notes.isEmpty)
              const Text('No notes yet', style: TextStyle(color: Colors.grey))
            else ...[
              const SizedBox(height: 8),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex -= 1;
                  setState(() {
                    final item = plan.notes.removeAt(oldIndex);
                    plan.notes.insert(newIndex, item);
                  });
                  try { await plan.save(); } catch (_) {}
                },
                children: plan.notes.asMap().entries.map((e) {
                  final idx = e.key;
                  final text = e.value;
                  return ListTile(
                    key: ValueKey('note_$idx'),
                    title: Text(text),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                        final controller = TextEditingController(text: text);
                        final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit note'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save'))]));
                        if (res == null || res.trim().isEmpty) return;
                        setState(() => plan.notes[idx] = res.trim());
                        try { await plan.save(); } catch (_) {}
                      }),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final removed = plan.notes.removeAt(idx);
                        setState(() {});
                        try { await plan.save(); } catch (_) {}
                        if (!mounted) return;
                        messenger.showSnackBar(SnackBar(content: const Text('Note deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => plan.notes.insert(idx, removed)); try { await plan.save(); } catch (_) {} })));
                      })
                    ]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Questions
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Questions', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: _addQuestion, icon: const Icon(Icons.add)),
            ]),
            if (plan.questions.isEmpty)
              const Text('No questions yet', style: TextStyle(color: Colors.grey))
            else ...[
              const SizedBox(height: 8),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex -= 1;
                  setState(() {
                    final item = plan.questions.removeAt(oldIndex);
                    plan.questions.insert(newIndex, item);
                  });
                  try { await plan.save(); } catch (_) {}
                },
                children: plan.questions.asMap().entries.map((e) {
                  final idx = e.key;
                  final text = e.value;
                  return ListTile(
                    key: ValueKey('q_$idx'),
                    title: Text(text),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                        final controller = TextEditingController(text: text);
                        final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit question'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save'))]));
                        if (res == null || res.trim().isEmpty) return;
                        setState(() => plan.questions[idx] = res.trim());
                        try { await plan.save(); } catch (_) {}
                      }),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final removed = plan.questions.removeAt(idx);
                        setState(() {});
                        try { await plan.save(); } catch (_) {}
                        if (!mounted) return;
                        messenger.showSnackBar(SnackBar(content: const Text('Question deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => plan.questions.insert(idx, removed)); try { await plan.save(); } catch (_) {} })));
                      })
                    ]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Flashcards
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: _addFlashcard, icon: const Icon(Icons.add)),
            ]),
            if (plan.flashcards.isEmpty)
              const Text('No flashcards yet', style: TextStyle(color: Colors.grey))
            else ...[
              const SizedBox(height: 8),
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) async {
                  if (newIndex > oldIndex) newIndex -= 1;
                  setState(() {
                    final item = plan.flashcards.removeAt(oldIndex);
                    plan.flashcards.insert(newIndex, item);
                  });
                  try { await plan.save(); } catch (_) {}
                },
                children: plan.flashcards.asMap().entries.map((e) {
                  final idx = e.key;
                  final f = e.value;
                  return ListTile(
                    key: ValueKey('fc_$idx'),
                    title: Text(f.front),
                    subtitle: Text(f.back),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                        final front = TextEditingController(text: f.front);
                        final back = TextEditingController(text: f.back);
                        final ok = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit flashcard'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: front, decoration: const InputDecoration(labelText: 'Front')), TextField(controller: back, decoration: const InputDecoration(labelText: 'Back'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))]));
                        if (ok != true) return;
                        setState(() => plan.flashcards[idx] = Flashcard(front: front.text.trim(), back: back.text.trim()));
                        try { await plan.save(); } catch (_) {}
                      }),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final removed = plan.flashcards.removeAt(idx);
                        setState(() {});
                        try { await plan.save(); } catch (_) {}
                        if (!mounted) return;
                        messenger.showSnackBar(SnackBar(content: const Text('Flashcard deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => plan.flashcards.insert(idx, removed)); try { await plan.save(); } catch (_) {} })));
                      })
                    ]),
                  );
                }).toList(),
              ),
            ]
          ]),
        ),
      ),
    );
  }

  Future<void> _addExplanation() async {
    final controller = TextEditingController();
    final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Add explanation'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
    if (res == null || res.trim().isEmpty) return;
    setState(() => plan.explanations.add(res.trim()));
    try { await plan.save(); } catch (_) {}
  }

  Future<void> _addNote() async {
    final controller = TextEditingController();
    final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Add note'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
    if (res == null || res.trim().isEmpty) return;
    setState(() => plan.notes.add(res.trim()));
    try { await plan.save(); } catch (_) {}
  }

  Future<void> _addQuestion() async {
    final controller = TextEditingController();
    final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Add question'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
    if (res == null || res.trim().isEmpty) return;
    setState(() => plan.questions.add(res.trim()));
    try { await plan.save(); } catch (_) {}
  }

  Future<void> _addFlashcard() async {
    final front = TextEditingController();
    final back = TextEditingController();
    final ok = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('Add flashcard'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: front, decoration: const InputDecoration(labelText: 'Front')), TextField(controller: back, decoration: const InputDecoration(labelText: 'Back'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add'))]));
    if (ok != true) return;
    final card = Flashcard(front: front.text.trim(), back: back.text.trim());
    setState(() => plan.flashcards.add(card));
    try { await plan.save(); } catch (_) {}
  }
}
