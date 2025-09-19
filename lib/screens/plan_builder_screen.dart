import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:hive/hive.dart';
import '../models/study_plan.dart';
import 'study_plan_detail_screen.dart';

class PlanBuilderScreen extends StatefulWidget {
  const PlanBuilderScreen({super.key});

  @override
  State<PlanBuilderScreen> createState() => _PlanBuilderScreenState();
}

class _PlanBuilderScreenState extends State<PlanBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String? _selectedSubject;

  final List<String> _subjects = ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'History'];
  final List<String> _extraSubjects = ['Economics', 'Sociology', 'Psychology', 'Computer Science', 'Law', 'Medicine', 'Engineering'];

  List<String> get _allSubjects => [..._subjects, ..._extraSubjects];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _createPlan() async {
    if (!_formKey.currentState!.validate()) return;
    final topic = _titleController.text.trim();
    final plan = StudyPlan(topic: topic, subject: _selectedSubject ?? 'General');
    final box = Hive.box<StudyPlan>('studyPlans');
    final idx = await box.add(plan);
    final saved = box.getAt(idx)!;
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => StudyPlanDetailScreen(plan: saved)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            TypeAheadFormField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                decoration: const InputDecoration(labelText: 'Subject (type or pick)'),
                controller: TextEditingController(text: _selectedSubject),
                onChanged: (v) => _selectedSubject = v,
              ),
              suggestionsCallback: (pattern) {
                final p = pattern.toLowerCase();
                return _allSubjects.where((s) => s.toLowerCase().contains(p)).toList();
              },
              itemBuilder: (context, s) => ListTile(title: Text(s)),
              onSuggestionSelected: (s) => setState(() => _selectedSubject = s),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please choose or type a subject' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Topic / Title'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a title' : null,
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _createPlan, child: const Text('Create')),
          ]),
        ),
      ),
    );
  }
}
