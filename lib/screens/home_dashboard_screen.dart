import 'package:flutter/material.dart';
import 'public_plans_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import '../services/local_sync_service.dart';
import '../services/firebase_auth_service.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../utils/file_parser.dart';
import '../utils/lesson_plan_generator.dart';
import 'study_plan_screen.dart';
import 'package:hive/hive.dart';
import '../models/study_plan.dart';

class HomeDashboard extends StatefulWidget {
  /// Optional testUserId helps widget tests avoid depending on Firebase Auth.
  final String? testUserId;
  final LocalSyncService? syncService;
  const HomeDashboard({super.key, this.testUserId, this.syncService});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _index = 0;
  int _pending = 0;
  bool _listenerStarted = false;

  @override
  void initState() {
    super.initState();
    // initialize pending count and start connectivity listener if we have a user
    _initPendingAndListener();
  }

  Future<void> _initPendingAndListener() async {
    try {
      final user = widget.testUserId != null ? null : AuthService().currentUser;
  final svc = widget.syncService ?? LocalSyncService();
      final c = await svc.pendingCount();
      if (mounted) setState(() => _pending = c);
      final userId = widget.testUserId ?? user?.uid;
      if (userId != null && !_listenerStarted) {
        svc.startConnectivityListener(userId);
        _listenerStarted = true;
      }
    } catch (_) {
      // ignore — safe in test environments where Firebase isn't initialized
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardTab = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome to Grade 12 Exam Prep Tutor', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Your Progress'),
              subtitle: const Text('View progress, streaks and recommendations'),
              onTap: () => Navigator.pushNamed(context, '/progress'),
            ),
          ),
          if (_pending > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Pending sync: $_pending', style: const TextStyle(color: Colors.orange)),
            ),
          Card(
            child: ListTile(
              title: const Text('Upload Materials'),
              subtitle: const Text('Parse PDFs and generate study plans'),
              onTap: () => Navigator.pushNamed(context, '/upload'),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Create Plan'),
              subtitle: const Text('Build a custom study plan'),
              onTap: () => Navigator.pushNamed(context, '/plan-builder'),
            ),
          ),
        ],
      ),
    );

    final myPlansTab = const Center(child: Text('My Plans will be listed here'));
    final communityTab = _index == 2 ? const PublicPlansScreen() : const Center(child: Text('Community'));
    final profileTab = _index == 3
        ? SingleChildScrollView(
            child: Column(
              children: const [
                SizedBox(height: 16),
                ProgressScreen(),
                SizedBox(height: 16),
                SettingsScreen(),
              ],
            ),
          )
        : const Center(child: Text('Profile'));

    final tabs = <Widget>[dashboardTab, myPlansTab, communityTab, profileTab];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import and generate study plans',
            onPressed: () async {
              try {
                final result = await FilePicker.platform.pickFiles(withData: true, allowedExtensions: ['pdf', 'ppt', 'pptx'], type: FileType.custom);
                if (result == null || result.files.isEmpty) return;
                final fileBytes = result.files.first.bytes;
                final temp = result.files.first.name;
                final dir = Directory.systemTemp;
                final f = File('${dir.path}/$temp');
                await f.writeAsBytes(fileBytes!);
                final text = await FileParser.extractText(f);
                final plans = await LessonPlanGenerator.generateFromText(text);
                final box = Hive.box<StudyPlan>('studyPlans');
                for (final p in plans) {
                  await box.add(p);
                }
                // Use local context reference after async work to avoid sync warnings.
                if (!mounted) return;
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StudyPlanScreen()));
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync Now',
              onPressed: () async {
              final user = AuthService().currentUser;
              final messenger = ScaffoldMessenger.of(context);
              final userId = widget.testUserId ?? user?.uid;
              if (userId == null) {
                messenger.showSnackBar(const SnackBar(content: Text('No user signed in.')));
                return;
              }
              try {
                final svc = widget.syncService ?? LocalSyncService();
                await svc.syncPending(userId);
                final c = await svc.pendingCount();
                if (mounted) setState(() => _pending = c);
                messenger.showSnackBar(const SnackBar(content: Text('Sync complete.')));
              } catch (e) {
                messenger.showSnackBar(const SnackBar(content: Text('Sync failed — will retry.')));
              }
            },
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'MyPlans'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
