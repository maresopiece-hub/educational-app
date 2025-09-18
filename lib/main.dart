import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_dashboard.dart';
import 'package:flutter/foundation.dart';
import 'providers/auth_state.dart';
import 'providers/settings_state.dart';
import 'services/notification_service.dart';

class InitializationErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const InitializationErrorScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Initialization Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Failed to initialize the app. Please check your network or configuration.'),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseOk = false;
  try {
    // Prevent duplicate initialization (fires on hot restart or if another
    // part of the app already initialized Firebase). See https://firebase.
    // google.com/docs/reference/android/com/google/firebase/FirebaseApp for
    // background. This avoids the [core/duplicate-app] error.
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    firebaseOk = true;
  } catch (e, st) {
    // Log to console for debugging; consider reporting to Sentry or similar.
    // If the native Android side already initialized Firebase (for example
    // via the Google Services plugin), the SDK may throw a duplicate-app
    // error. Treat that as success so the Flutter app continues.
    if (e is FirebaseException && e.code == 'duplicate-app') {
      firebaseOk = true;
      if (kDebugMode) print('Firebase already initialized (duplicate-app) — continuing.');
    } else {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
        print(st);
      }
    }
  }

  // Initialize local notification service once Firebase (and platform) are ready.
  if (firebaseOk) {
    try {
      await NotificationService().init();
      if (kDebugMode) print('NotificationService initialized');
    } catch (e) {
      if (kDebugMode) print('NotificationService init failed: $e');
    }
  }

  runApp(MyApp(firebaseOk: firebaseOk));
}

class MyApp extends StatelessWidget {
  final bool firebaseOk;

  const MyApp({super.key, required this.firebaseOk});

  @override
  Widget build(BuildContext context) {
    if (!firebaseOk) {
      // Show a minimal retry screen when initialization fails.
      return InitializationErrorScreen(
        onRetry: () async {
          // A simple retry action: try initializing Firebase again and restart the app.
          try {
            if (Firebase.apps.isEmpty) {
              await Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform,
              );
            }
            // If successful, force a rebuild by using Navigator to push replacement.
            // In a larger app you might use better state management to reflect this.
            runApp(const MyApp(firebaseOk: true));
          } catch (e) {
            if (kDebugMode) print('Retry failed: $e');
          }
        },
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(create: (_) => SettingsState()),
      ],
      child: MaterialApp(
        title: 'Grade12 Exam Prep Tutor',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: '/auth',
        routes: {
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeDashboard(),
        },
      ),
    );
  }
}
