import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_dashboard.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Add providers here as needed
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
