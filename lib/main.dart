import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'pages/arc_setup_page.dart';
import 'pages/home_dashboard.dart';
import 'utils/storage_helper.dart';
import 'utils/notification_helper.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezones for notifications
  tz.initializeTimeZones();
  
  // Initialize notifications
  await NotificationHelper.initialize();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const WinterArcApp(),
    ),
  );
}

class WinterArcApp extends StatelessWidget {
  const WinterArcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'The Winter Arc',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.getThemeData(),
          home: const AppInitializer(),
        );
      },
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
