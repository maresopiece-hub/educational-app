import 'package:flutter/material.dart';
import '../services/database_service.dart';

class ProgressWidget extends StatefulWidget {
  final String userId;
  const ProgressWidget({Key? key, required this.userId}) : super(key: key);

  @override
  State<ProgressWidget> createState() => _ProgressWidgetState();
}

class _ProgressWidgetState extends State<ProgressWidget> {
  double _overallProgress = 0;
  int _streak = 0;
  int _badges = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _loading = true);
    // Example: Fetch from local DB
    final db = DatabaseService.instance;
    // TODO: Replace with real queries
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _overallProgress = 0.65; // 65% complete (example)
      _streak = 7; // 7-day streak (example)
      _badges = 3; // 3 badges earned (example)
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progress', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: _overallProgress),
            const SizedBox(height: 8),
            Text('Overall: ${(_overallProgress * 100).toStringAsFixed(1)}%'),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.local_fire_department, color: Colors.orange),
                const SizedBox(width: 4),
                Text('Streak: $_streak days'),
                const SizedBox(width: 16),
                Icon(Icons.emoji_events, color: Colors.amber),
                const SizedBox(width: 4),
                Text('Badges: $_badges'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
