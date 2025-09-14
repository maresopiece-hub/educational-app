import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pdf_upload_screen.dart';
import 'screens/import_screen.dart';
import 'screens/exam_mode_screen.dart';
import 'screens/create_plan_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/study_today_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (!themeProvider.initialized) {
      return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
    }
    return MaterialApp(
      title: 'Grade12 Exam Prep Tutor',
      theme: AppTheme.light(themeProvider.color),
      darkTheme: AppTheme.dark(themeProvider.color),
      themeMode: ThemeMode.system,
      initialRoute: '/auth',
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
        '/upload': (context) => const PDFUploadScreen(),
  '/import': (context) => const ImportScreen(),
  '/study': (context) => const StudyTodayScreen(),
        '/exam': (context) => const ExamModeScreen(),
        '/create': (context) => const CreatePlanScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title (to be implemented)')),
    );
  }
}
