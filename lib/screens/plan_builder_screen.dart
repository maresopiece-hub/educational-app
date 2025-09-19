import 'package:flutter/material.dart';
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
    // Hive.box.add returns the key for the stored value. Use box.get(key)
    // rather than getAt(index) because keys and positional indices can differ
    // (sparse keys or deleted entries). getAt expects a positional index
    // and will throw if the index is out of range.
  final key = await box.add(plan);
  final saved = box.get(key) ?? plan;
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
            // simple Autocomplete to pick or type subject
            Autocomplete<String>(
              initialValue: TextEditingValue(text: _selectedSubject ?? ''),
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text == '') return const Iterable<String>.empty();
                final q = textEditingValue.text.toLowerCase();
                return _allSubjects.where((s) => s.toLowerCase().contains(q));
              },
              onSelected: (s) => setState(() => _selectedSubject = s),
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Subject (type or pick)'),
                  onChanged: (v) => _selectedSubject = v,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Please choose or type a subject' : null,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: options.map((o) => ListTile(title: Text(o), onTap: () => onSelected(o))).toList(),
                      ),
                    ),
                  ),
                );
              },
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
