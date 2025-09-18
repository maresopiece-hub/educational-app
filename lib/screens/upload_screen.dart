import 'package:flutter/material.dart';
import '../services/file_processor_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String _status = 'Idle';

  Future<void> _pickAndProcess() async {
    setState(() => _status = 'Picking...');
    try {
      final result = await FileProcessorService().pickAndParse();
      setState(() => _status = result ?? 'No content parsed');
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(onPressed: _pickAndProcess, child: const Text('Pick File')),
            const SizedBox(height: 16),
            Text('Status: $_status'),
          ],
        ),
      ),
    );
  }
}
