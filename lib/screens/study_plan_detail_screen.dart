import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/study_plan.dart';
import 'subtopic_detail_screen.dart';
import 'study_mode_screen.dart';

class StudyPlanDetailScreen extends StatefulWidget {
  final StudyPlan plan;
  const StudyPlanDetailScreen({super.key, required this.plan});

  @override
  State<StudyPlanDetailScreen> createState() => _StudyPlanDetailScreenState();
}

class _StudyPlanDetailScreenState extends State<StudyPlanDetailScreen> {
  late StudyPlan plan;
  late String selectedQuestionType;

  @override
  void initState() {
    super.initState();
    plan = widget.plan;
    selectedQuestionType = plan.defaultQuestionType;
  }

  Future<void> _promptAddSubtopic() async {
    // Ask only for the subtopic title, then create an empty Subtopic
    final controller = TextEditingController();
    final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Add subtopic'), content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Subtopic title')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
    if (res == null || res.trim().isEmpty) return;
    setState(() {
      final st = Subtopic(title: res.trim());
      // create empty containers for the user to later populate
      st.explanations = <String>[];
      st.notes = <String>[];
      st.questions = <Question>[];
      st.flashcards = <Flashcard>[];
      plan.subtopics.add(st);
    });
    try { await plan.save(); } catch (_) {}
  }

  Future<Question?> _showQuestionEditor(BuildContext context, Question initial) async {
    final promptCtrl = TextEditingController(text: initial.prompt);
    final typeCtrl = ValueNotifier<String>(initial.type);
    final answerCtrl = TextEditingController(text: initial.answer);
    final explanationCtrl = TextEditingController(text: initial.explanation);
    final choicesCtrls = initial.choices.map((c) => TextEditingController(text: c)).toList();

    Question? buildResult() {
      final choices = choicesCtrls.map((c) => c.text.trim()).where((s) => s.isNotEmpty).toList();
      return Question(type: typeCtrl.value, prompt: promptCtrl.text.trim(), choices: choices, answer: answerCtrl.text.trim(), explanation: explanationCtrl.text.trim());
    }

    return showDialog<Question?>(context: context, builder: (ctx) {
      return AlertDialog(
        title: const Text('Question'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: promptCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Prompt')),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(valueListenable: typeCtrl, builder: (_, t, __) => DropdownButton<String>(value: t, items: const [DropdownMenuItem(value: 'mcq', child: Text('MCQ')), DropdownMenuItem(value: 'tf', child: Text('True/False')), DropdownMenuItem(value: 'fill', child: Text('Fill')), DropdownMenuItem(value: 'essay', child: Text('Essay'))], onChanged: (v) { if (v != null) typeCtrl.value = v; })),
            const SizedBox(height: 8),
            if (typeCtrl.value == 'mcq') ...[
              const Text('Choices'),
              const SizedBox(height: 6),
              ...choicesCtrls.map((c) => Padding(padding: const EdgeInsets.symmetric(vertical: 4.0), child: TextField(controller: c, decoration: const InputDecoration(labelText: 'Choice')))).toList(),
              TextButton(onPressed: () => choicesCtrls.add(TextEditingController()), child: const Text('Add choice'))
            ],
            const SizedBox(height: 8),
            TextField(controller: answerCtrl, decoration: const InputDecoration(labelText: 'Answer')),
            const SizedBox(height: 8),
            TextField(controller: explanationCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Explanation (optional)')),
          ]),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(ctx, buildResult()), child: const Text('Save'))],
      );
    });
  }

  Future<Question?> _showMcqCreator(BuildContext ctx) async {
    final prompt = TextEditingController();
    final a = TextEditingController();
    final b = TextEditingController();
    final cCtrl = TextEditingController();
    final d = TextEditingController();
    final e = TextEditingController();
    final f = TextEditingController();
    final answer = TextEditingController();
    final explanation = TextEditingController();

    return showDialog<Question?>(context: ctx, builder: (_) {
      return AlertDialog(
        title: const Text('Create MCQ'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: prompt, decoration: const InputDecoration(labelText: 'Question')),
            const SizedBox(height: 8),
            const Align(alignment: Alignment.centerLeft, child: Text('Choices (A–D required, E/F optional)', style: TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(height: 6),
            TextField(controller: a, decoration: const InputDecoration(labelText: 'A')),
            TextField(controller: b, decoration: const InputDecoration(labelText: 'B')),
            TextField(controller: cCtrl, decoration: const InputDecoration(labelText: 'C')),
            TextField(controller: d, decoration: const InputDecoration(labelText: 'D')),
            TextField(controller: e, decoration: const InputDecoration(labelText: 'E (optional)')),
            TextField(controller: f, decoration: const InputDecoration(labelText: 'F (optional)')),
            const SizedBox(height: 8),
            TextField(controller: answer, decoration: const InputDecoration(labelText: 'Answer (A–F)')),
            const SizedBox(height: 8),
            TextField(controller: explanation, maxLines: 3, decoration: const InputDecoration(labelText: 'Explanation (optional)')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('Cancel')),
          TextButton(onPressed: () {
            // validation: A-D must be non-empty
            if (a.text.trim().isEmpty || b.text.trim().isEmpty || cCtrl.text.trim().isEmpty || d.text.trim().isEmpty) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please fill choices A to D')));
              return;
            }
            final ans = answer.text.trim().toUpperCase();
            if (ans.isEmpty || !'ABCDEF'.contains(ans)) {
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Please provide a valid answer letter (A–F)')));
              return;
            }
            // build choices list preserving order and skipping empty optional ones
            final choices = <String>[a.text.trim(), b.text.trim(), cCtrl.text.trim(), d.text.trim()];
            if (e.text.trim().isNotEmpty) choices.add(e.text.trim());
            if (f.text.trim().isNotEmpty) choices.add(f.text.trim());
            // convert answer letter to index-based answer storage: we'll store the letter per requirement
            final q = Question(type: 'mcq', prompt: prompt.text.trim(), choices: choices, answer: ans, explanation: explanation.text.trim());
            Navigator.pop(ctx, q);
          }, child: const Text('Create'))
        ],
      );
    });
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
      appBar: AppBar(
        title: Text(plan.topic),
        actions: [
          // keep primary actions visible
          IconButton(onPressed: _promptAddSubtopic, icon: const Icon(Icons.add)),
          IconButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => StudyModeScreen(plan: plan))); setState(() {}); }, icon: const Icon(Icons.school)),
          // group less-frequent actions into a popup menu to avoid overflow on narrow screens
          PopupMenuButton<String>(
            onSelected: (v) async {
              if (v == 'export') return _exportJson();
              if (v == 'edit') return _editTitle();
              if (v == 'settings') {
                final sel = await showDialog<String?>(context: context, builder: (_) => SimpleDialog(title: const Text('Default question type'), children: [SimpleDialogOption(onPressed: () => Navigator.pop(context, 'mcq'), child: const Text('Multiple choice (mcq)')), SimpleDialogOption(onPressed: () => Navigator.pop(context, 'tf'), child: const Text('True / False (tf)')), SimpleDialogOption(onPressed: () => Navigator.pop(context, 'fill'), child: const Text('Fill in the blank (fill)')), SimpleDialogOption(onPressed: () => Navigator.pop(context, 'essay'), child: const Text('Explain (essay)'))]));
                if (sel != null && sel.isNotEmpty) {
                  setState(() => plan.defaultQuestionType = sel);
                  try { await plan.save(); } catch (_) {}
                }
                return;
              }
              if (v == 'delete') return _confirmDelete();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'export', child: Text('Export JSON')),
              PopupMenuItem(value: 'edit', child: Text('Edit title')),
              PopupMenuItem(value: 'settings', child: Text('Default question type')),
              PopupMenuItem(value: 'delete', child: Text('Delete plan')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(plan.topic, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const SizedBox(height: 8),
            // ...existing content (removed top Questions header) ...
            // Subtopics (nested)
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Subtopics', style: TextStyle(fontWeight: FontWeight.bold)),
              IconButton(onPressed: _promptAddSubtopic, icon: const Icon(Icons.add)),
            ]),
            if (plan.subtopics.isEmpty)
              const Text('No subtopics yet', style: TextStyle(color: Colors.grey))
            else ...[
              const SizedBox(height: 8),
              ...plan.subtopics.map((st) => ExpansionTile(
                    title: Text(st.title),
                    children: [
                      // Explanations for subtopic (mirror main-topic behavior)
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Explanations', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () async {
                          final controller = TextEditingController();
                          final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Add explanation'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
                          if (res == null || res.trim().isEmpty) return;
                          setState(() => st.explanations.add(res.trim()));
                          try { await plan.save(); } catch (_) {}
                        }, icon: const Icon(Icons.add)),
                      ]),
                      if (st.explanations.isEmpty)
                        const Text('No explanations yet', style: TextStyle(color: Colors.grey))
                      else ...[
                        const SizedBox(height: 8),
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) newIndex -= 1;
                            setState(() {
                              final item = st.explanations.removeAt(oldIndex);
                              st.explanations.insert(newIndex, item);
                            });
                            try { await plan.save(); } catch (_) {}
                          },
                          children: st.explanations.asMap().entries.map((e) {
                            final i = e.key;
                            final text = e.value;
                            return ListTile(
                              key: ValueKey('st_${st.title}_exp_$i'),
                              title: Text(text),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                                  final controller = TextEditingController(text: text);
                                  final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit explanation'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save'))]));
                                  if (res == null || res.trim().isEmpty) return;
                                  setState(() => st.explanations[i] = res.trim());
                                  try { await plan.save(); } catch (_) {}
                                }),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final removed = st.explanations.removeAt(i);
                                  setState(() {});
                                  try { await plan.save(); } catch (_) {}
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(content: const Text('Explanation deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => st.explanations.insert(i, removed)); try { await plan.save(); } catch (_) {} })));
                                })
                              ]),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Notes for subtopic
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Notes', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () async {
                          final controller = TextEditingController();
                          final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Add note'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
                          if (res == null || res.trim().isEmpty) return;
                          setState(() => st.notes.add(res.trim()));
                          try { await plan.save(); } catch (_) {}
                        }, icon: const Icon(Icons.add)),
                      ]),
                      if (st.notes.isEmpty)
                        const Text('No notes yet', style: TextStyle(color: Colors.grey))
                      else ...[
                        const SizedBox(height: 8),
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) newIndex -= 1;
                            setState(() {
                              final item = st.notes.removeAt(oldIndex);
                              st.notes.insert(newIndex, item);
                            });
                            try { await plan.save(); } catch (_) {}
                          },
                          children: st.notes.asMap().entries.map((e) {
                            final i = e.key;
                            final text = e.value;
                            return ListTile(
                              key: ValueKey('st_${st.title}_note_$i'),
                              title: Text(text),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                                  final controller = TextEditingController(text: text);
                                  final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit note'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save'))]));
                                  if (res == null || res.trim().isEmpty) return;
                                  setState(() => st.notes[i] = res.trim());
                                  try { await plan.save(); } catch (_) {}
                                }),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final removed = st.notes.removeAt(i);
                                  setState(() {});
                                  try { await plan.save(); } catch (_) {}
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(content: const Text('Note deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => st.notes.insert(i, removed)); try { await plan.save(); } catch (_) {} })));
                                })
                              ]),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Flashcards for subtopic
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Flashcards', style: TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(onPressed: () async {
                          final front = TextEditingController();
                          final back = TextEditingController();
                          final ok = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('Add flashcard'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: front, decoration: const InputDecoration(labelText: 'Front')), TextField(controller: back, decoration: const InputDecoration(labelText: 'Back'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add'))]));
                          if (ok != true) return;
                          setState(() => st.flashcards.add(Flashcard(front: front.text.trim(), back: back.text.trim())));
                          try { await plan.save(); } catch (_) {}
                        }, icon: const Icon(Icons.add)),
                      ]),
                      if (st.flashcards.isEmpty)
                        const Text('No flashcards yet', style: TextStyle(color: Colors.grey))
                      else ...[
                        const SizedBox(height: 8),
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) newIndex -= 1;
                            setState(() {
                              final item = st.flashcards.removeAt(oldIndex);
                              st.flashcards.insert(newIndex, item);
                            });
                            try { await plan.save(); } catch (_) {}
                          },
                          children: st.flashcards.asMap().entries.map((e) {
                            final i = e.key;
                            final f = e.value;
                            return ListTile(
                              key: ValueKey('st_${st.title}_fc_$i'),
                              title: Text(f.front),
                              subtitle: Text(f.back),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                                  final front = TextEditingController(text: f.front);
                                  final back = TextEditingController(text: f.back);
                                  final ok = await showDialog<bool?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit flashcard'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: front, decoration: const InputDecoration(labelText: 'Front')), TextField(controller: back, decoration: const InputDecoration(labelText: 'Back'))]), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save'))]));
                                  if (ok != true) return;
                                  setState(() => st.flashcards[i] = Flashcard(front: front.text.trim(), back: back.text.trim()));
                                  try { await plan.save(); } catch (_) {}
                                }),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final removed = st.flashcards.removeAt(i);
                                  setState(() {});
                                  try { await plan.save(); } catch (_) {}
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(content: const Text('Flashcard deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => st.flashcards.insert(i, removed)); try { await plan.save(); } catch (_) {} })));
                                })
                              ]),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Questions for subtopic
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('Questions', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(children: [
                          DropdownButton<String>(value: selectedQuestionType, items: const [
                            DropdownMenuItem(value: 'mcq', child: Text('MCQ')),
                            DropdownMenuItem(value: 'tf', child: Text('True/False')),
                            DropdownMenuItem(value: 'fill', child: Text('Fill')),
                            DropdownMenuItem(value: 'essay', child: Text('Essay')),
                          ], onChanged: (v) async { if (v == null) return; setState(() { selectedQuestionType = v; plan.defaultQuestionType = v; }); try { await plan.save(); } catch (_) {} }),
                          IconButton(onPressed: () async { final q = await _showQuestionEditor(context, Question(type: plan.defaultQuestionType, prompt: '')); if (q == null) return; setState(() => st.questions.add(q)); try { await plan.save(); } catch (_) {} }, icon: const Icon(Icons.add))
                        ])
                      ]),
                      if (st.questions.isEmpty)
                        const Text('No questions yet', style: TextStyle(color: Colors.grey))
                      else ...[
                        const SizedBox(height: 8),
                        ReorderableListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          onReorder: (oldIndex, newIndex) async {
                            if (newIndex > oldIndex) newIndex -= 1;
                            setState(() {
                              final item = st.questions.removeAt(oldIndex);
                              st.questions.insert(newIndex, item);
                            });
                            try { await plan.save(); } catch (_) {}
                          },
                          children: st.questions.asMap().entries.map((e) {
                            final i = e.key;
                            final q = e.value;
                            return ListTile(
                              key: ValueKey('st_${st.title}_q_$i'),
                              title: Text(q.prompt),
                              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                                  final res = await _showQuestionEditor(context, q);
                                  if (res == null) return;
                                  setState(() => st.questions[i] = res);
                                  try { await plan.save(); } catch (_) {}
                                }),
                                IconButton(icon: const Icon(Icons.delete), onPressed: () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final removed = st.questions.removeAt(i);
                                  setState(() {});
                                  try { await plan.save(); } catch (_) {}
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(content: const Text('Question deleted'), action: SnackBarAction(label: 'Undo', onPressed: () async { setState(() => st.questions.insert(i, removed)); try { await plan.save(); } catch (_) {} })));
                                })
                              ]),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                      // actions (open/edit) using Wrap to avoid overflow
                      Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Wrap(spacing: 8, children: [TextButton(onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => SubtopicDetailScreen(plan: plan, path: [st]))); setState(() {}); }, child: const Text('Open')), TextButton(onPressed: () async { final controller = TextEditingController(text: st.title); final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Edit subtopic title'), content: TextField(controller: controller), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save'))])); if (res != null && res.trim().isNotEmpty) { setState(() => st.title = res.trim()); try { await plan.save(); } catch (_) {} } }, child: const Text('Edit'))])),
                    ],
                  )).toList(),
              const SizedBox(height: 12),
            ],
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

            // Questions (moved default-question-type dropdown here)
            Row(children: [
              const Expanded(child: Text('Questions', style: TextStyle(fontWeight: FontWeight.bold))),
              DropdownButton<String>(value: selectedQuestionType, items: const [
                DropdownMenuItem(value: 'mcq', child: Text('MCQ')),
                DropdownMenuItem(value: 'tf', child: Text('True/False')),
                DropdownMenuItem(value: 'fill', child: Text('Fill')),
                DropdownMenuItem(value: 'essay', child: Text('Essay')),
              ], onChanged: (v) async {
                if (v == null) return;
                setState(() {
                  selectedQuestionType = v;
                  plan.defaultQuestionType = v;
                });
                try {
                  await plan.save();
                } catch (_) {}
              }),
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
                    final q = e.value;
                    return ListTile(
                      key: ValueKey('q_$idx'),
                      title: Text(q.prompt),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () async {
                          final res = await _showQuestionEditor(context, q);
                          if (res == null) return;
                          setState(() => plan.questions[idx] = res);
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
    // Use the currently selected question type (from the dropdown next to the +)
    if (selectedQuestionType == 'mcq') {
      final q = await _showMcqCreator(context);
      if (q == null) return;
      setState(() => plan.questions.add(q));
      try { await plan.save(); } catch (_) {}
      return;
    }

    // Fallback simple add for other types: prompt-only
    final controller = TextEditingController();
    final res = await showDialog<String?>(context: context, builder: (_) => AlertDialog(title: const Text('Add question'), content: TextField(controller: controller, maxLines: 4), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Add'))]));
    if (res == null || res.trim().isEmpty) return;
    setState(() => plan.questions.add(Question(type: selectedQuestionType, prompt: res.trim())));
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
