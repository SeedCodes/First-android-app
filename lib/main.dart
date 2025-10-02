import 'package:flutter/material.dart';
import 'pages/arc_setup_page.dart';
import 'pages/home_dashboard.dart';
import 'utils/storage_helper.dart';

void main() {
  runApp(const WinterArcApp());
}

class WinterArcApp extends StatelessWidget {
  const WinterArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Winter Arc',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFF50C878),
          surface: const Color(0xFF1D1E33),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
      ),
      home: const AppInitializer(),
    );
  }
}

// Widget to determine initial route based on saved data
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: StorageHelper.hasArcData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4A90E2),
              ),
            ),
          );
        }

        final hasArc = snapshot.data ?? false;
        return hasArc ? const HomeDashboard() : const ArcSetupPage();
      },
    );
  }
}
