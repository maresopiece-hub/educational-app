import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../services/firestore_service.dart';
import '../services/firebase_auth_service.dart';
import '../services/local_sync_service.dart';
import '../services/notification_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late final ConfettiController _confettiController;
  double _percent = 0.0;
  final Set<int> _celebrated = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAndSync());
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _loadAndSync() async {
    final user = AuthService().currentUser;
    if (user == null) {
      setState(() {
        _error = 'You must be logged in to view progress.';
        _loading = false;
      });
      return;
    }

    try {
      await LocalSyncService().syncPending(user.uid);
    } catch (e) {
      // ignore errors during sync here; we'll still try to show progress
    }

    try {
      final data = await FirestoreService().getUserProgress(user.uid);
      // Compute percent as average of completed topics if available.
      double percent = 0.0;
      if (data.isNotEmpty) {
        // expecting each progress doc to contain a "completedPercent" numeric field
        final vals = data.map((d) => (d['completedPercent'] ?? 0).toDouble()).toList();
        percent = vals.fold(0.0, (a, b) => a + b) / vals.length;
      }
      setState(() {
        _percent = percent;
        _loading = false;
      });
      _checkMilestones(percent);
      // If below threshold, schedule a daily nudge (non-blocking). Avoid using
      // the BuildContext across async gaps by checking `mounted` first.
      if (!mounted) return;
      if (percent < 50) {
        try {
          await DefaultNotificationService().scheduleNudge(context, 50, 'Review weak topics!');
        } catch (e) {
          // ignore scheduling errors
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading progress: $e';
        _loading = false;
      });
    }
  }

  void _checkMilestones(double percent) {
    final milestones = [25, 50, 75, 100];
    for (final m in milestones) {
      if (percent >= m && !_celebrated.contains(m)) {
        _celebrated.add(m);
        _confettiController.play();
      }
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
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Completion: ${_percent.toStringAsFixed(1)}%'),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: _percent / 100.0),
              ],
            ),
          ),
          Positioned(
            top: 0,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              shouldLoop: false,
            ),
          ),
        ],
      ),
    );
  }
}
