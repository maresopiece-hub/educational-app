import 'package:flutter/material.dart';
import 'public_plans_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import '../services/local_sync_service.dart';
import '../services/firebase_auth_service.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _index = 0;
  int _pending = 0;

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null) {
      LocalSyncService().startConnectivityListener(user.uid);
      LocalSyncService().pendingCount().then((c) => setState(() => _pending = c));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      // Dashboard tab
      Padding(
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
      ),
      // MyPlans placeholder
      const Center(child: Text('My Plans will be listed here')),
      // Community
      const PublicPlansScreen(),
      // Profile: combine progress and settings
      SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 16),
            ProgressScreen(),
            SizedBox(height: 16),
            SettingsScreen(),
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
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
