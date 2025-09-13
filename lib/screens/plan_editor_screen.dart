
import 'package:flutter/material.dart';
import '../models/lesson_plan_model.dart';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';


class PlanEditorScreen extends StatefulWidget {
  final LessonPlan? initialPlan;
  const PlanEditorScreen({super.key, this.initialPlan});

  @override
  State<PlanEditorScreen> createState() => _PlanEditorScreenState();
}

class _PlanEditorScreenState extends State<PlanEditorScreen> {
  late List<LessonPlanSection> _sections;
  bool _isPublic = false;
  final TextEditingController _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPlan != null) {
      _sections = List<LessonPlanSection>.from(widget.initialPlan!.sections);
      _isPublic = widget.initialPlan!.isPublic;
      _titleController.text = widget.initialPlan!.title;
    } else {
      _sections = [];
    }
  }

  void _addSection() {
    setState(() {
      _sections.add(LessonPlanSection(
        explanation: '',
        examples: [],
        questions: [],
        complete: false,
      ));
    });
  }

  void _editExplanation(int index, String content) {
    setState(() {
      _sections[index].explanation = content;
    });
  }

  void _editExamples(int index, String content) {
    setState(() {
      _sections[index].examples = content.split(';').map((e) => e.trim()).toList();
    });
  }

  void _removeSection(int index) {
    setState(() {
      _sections.removeAt(index);
    });
  }

  void _reorderSection(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _sections.removeAt(oldIndex);
      _sections.insert(newIndex, item);
    });
  }

  void _savePlan() async {
    final user = AuthService().currentUser;
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to save your plan.')),
      );
      return;
    }
    final plan = LessonPlan(
      title: _titleController.text,
      sections: _sections,
      isPublic: _isPublic,
    );
    try {
      await FirestoreService().saveUserPlan(user.uid, plan.toMap());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan saved to cloud!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving plan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Editor'),
        actions: [
          Switch(
            value: _isPublic,
            onChanged: (val) => setState(() => _isPublic = val),
            activeThumbColor: Colors.green,
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Center(child: Text('Public')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Plan Title'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView(
                onReorder: _reorderSection,
                children: [
                  for (int i = 0; i < _sections.length; i++)
                    Card(
                      key: ValueKey(i),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Section ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeSection(i),
                                ),
                              ],
                            ),
                            TextFormField(
                              initialValue: _sections[i].explanation,
                              onChanged: (val) => _editExplanation(i, val),
                              decoration: const InputDecoration(labelText: 'Explanation'),
                              maxLines: null,
                            ),
                            TextFormField(
                              initialValue: _sections[i].examples.join('; '),
                              onChanged: (val) => _editExamples(i, val),
                              decoration: const InputDecoration(labelText: 'Examples (separate with ;)'),
                              maxLines: null,
                            ),
                            const SizedBox(height: 8),
                            const Text('Questions:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ..._sections[i].questions.map((q) => ListTile(
                                  title: Text(q['question'] ?? ''),
                                  subtitle: Text('Answer: ${q['answer'] ?? ''}'),
                                )),
                            if (_sections[i].note != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text('Note: ${_sections[i].note}', style: const TextStyle(color: Colors.orange)),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addSection,
                  child: const Text('Add Section'),
                ),
                ElevatedButton(
                  onPressed: _savePlan,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
