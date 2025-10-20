import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import 'background/worker_callback.dart';
import 'screens/create_account_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';

const String backgroundTaskName = "journy_background_task";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await StorageService.init();

  await NotificationService().init();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // Register background periodic task
  Workmanager().registerPeriodicTask(
    "journy_periodic_task",
    backgroundTaskName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    constraints: Constraints(
      networkType: NetworkType.not_required,
      requiresBatteryNotLow: false,
      requiresCharging: false,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final loggedIn = StorageService.read<bool>('isLoggedIn') ?? false;
    setState(() {
      _isLoggedIn = loggedIn;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Simple splash/loading while reading SharedPreferences
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'Journy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey[50],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: _isLoggedIn ? const HomeScreen() : const CreateAccountScreen(),
    );
  }
}
