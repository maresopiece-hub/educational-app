import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/file_processor.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  String? _fileName;
  String? _fileType;
  bool _loading = false;
  String? _error;
  String? _planPreview;

  Future<void> _pickFile() async {
    setState(() { _error = null; });
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'pptx']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileType = result.files.single.extension;
      });
    }
  }

  Future<void> _generatePlan() async {
    if (_fileType == null) return;
    setState(() { _loading = true; _error = null; _planPreview = null; });
    try {
      final processor = FileProcessor();
      final text = await processor.extractTextFromFile(_fileType!);
      final sections = processor.divideSections(text);
      final plan = processor.generateLessonPlan(sections);
      setState(() {
        _planPreview = plan.toString();
      });
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Study Material')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Select PDF or PPTX'),
              onPressed: _pickFile,
            ),
            if (_fileName != null) ...[
              const SizedBox(height: 16),
              Text('Selected: $_fileName'),
              ElevatedButton(
                onPressed: _loading ? null : _generatePlan,
                child: _loading ? const CircularProgressIndicator() : const Text('Generate Lesson Plan'),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_planPreview != null) ...[
              const SizedBox(height: 24),
              const Text('Plan Preview:'),
              SingleChildScrollView(
                child: Text(_planPreview!, maxLines: 10, overflow: TextOverflow.ellipsis),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
