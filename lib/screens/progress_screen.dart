import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';


class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<Map<String, dynamic>> _progress = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = AuthService().currentUser;
    if (user == null) {
      setState(() {
        _error = 'You must be logged in to view progress.';
        _loading = false;
      });
      return;
    }
    try {
      final data = await FirestoreService().getUserProgress(user.uid);
      setState(() {
        _progress = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading progress: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progress')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Progress')),
        body: Center(child: Text(_error!)),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: _progress.isEmpty
          ? const Center(child: Text('No progress data found.'))
          : ListView.builder(
              itemCount: _progress.length,
              itemBuilder: (context, i) {
                final p = _progress[i];
                return ListTile(
                  title: Text(p['title'] ?? 'Untitled'),
                  subtitle: Text('Score: ${p['score'] ?? '-'} | Date: ${p['date'] ?? '-'}'),
                );
              },
            ),
    );
  }
}
