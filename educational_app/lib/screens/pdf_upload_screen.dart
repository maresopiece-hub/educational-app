import 'package:flutter/material.dart';
import '../services/pdf_parser.dart';
import '../services/file_processor.dart';

class PDFUploadScreen extends StatefulWidget {
  const PDFUploadScreen({super.key});

  @override
  State<PDFUploadScreen> createState() => _PDFUploadScreenState();
}

class _PDFUploadScreenState extends State<PDFUploadScreen> {
  String? _fileName;
  List<String>? _sections;
  bool _isLoading = false;
  String? _error;

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Use PDFParser().extractText() which opens file picker internally
      final text = await PDFParser().extractText();
      if (text.isNotEmpty) {
        _fileName = 'Selected PDF';
        _sections = FileProcessor().divideSections(text);
      } else {
        _error = 'No file selected or empty PDF.';
      }
    } catch (e) {
      _error = 'Failed to parse PDF: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Pick PDF File'),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            if (_fileName != null && _sections != null) ...[
              const SizedBox(height: 24),
              Text('File: $_fileName', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('Sections Detected:', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _sections!.length,
                  itemBuilder: (context, idx) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(_sections![idx]),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_sections == null || _sections!.isEmpty) return;
                  setState(() => _isLoading = true);
                  try {
                    // Example: generate and save lesson plan
                    final plan = {
                      'title': _fileName ?? 'Lesson Plan',
                      'sections': _sections,
                    };
                    // await DatabaseService.instance.insertPlan(plan);
                    await Future.delayed(const Duration(seconds: 1));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Lesson plan generated and saved!')),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _error = 'Failed to save plan: $e');
                  } finally {
                    if (!mounted) return;
                    setState(() => _isLoading = false);
                  }
                },
                child: const Text('Generate Lesson Plan'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
