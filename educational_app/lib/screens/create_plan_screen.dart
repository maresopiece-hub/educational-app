import 'package:flutter/material.dart';

class CreatePlanScreen extends StatefulWidget {
  const CreatePlanScreen({Key? key}) : super(key: key);

  @override
  State<CreatePlanScreen> createState() => _CreatePlanScreenState();
}

class _CreatePlanScreenState extends State<CreatePlanScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<TextEditingController> _sectionControllers = [TextEditingController()];
  bool _isPublic = false;
  bool _saving = false;
  String? _error;

  void _addSection() {
    setState(() {
      _sectionControllers.add(TextEditingController());
    });
  }

  void _removeSection(int idx) {
    setState(() {
      if (_sectionControllers.length > 1) {
        _sectionControllers.removeAt(idx);
      }
    });
  }

  Future<void> _savePlan() async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      // TODO: Save plan to local DB or upload if public
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = 'Failed to save: $e';
      });
    } finally {
      setState(() {
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Lesson Plan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Plan Title'),
            ),
            const SizedBox(height: 16),
            const Text('Sections:'),
            ..._sectionControllers.asMap().entries.map((entry) {
              final idx = entry.key;
              final controller = entry.value;
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Section ${idx + 1}'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeSection(idx),
                  ),
                ],
              );
            }),
            TextButton.icon(
              onPressed: _addSection,
              icon: const Icon(Icons.add),
              label: const Text('Add Section'),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              value: _isPublic,
              onChanged: (val) => setState(() => _isPublic = val),
              title: const Text('Make Public'),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            _saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _savePlan,
                    child: const Text('Save Plan'),
                  ),
          ],
        ),
      ),
    );
  }
}
