import 'package:flutter/material.dart';
import '../services/streak_service.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import 'create_account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String status = '';
  double profileCompletion = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final profile = StorageService.read<bool>('profile_completed') ?? false;
    final streak = StorageService.read<int>('streak') ?? 0;
    final coins = StorageService.read<int>('coins') ?? 0;
    final name = StorageService.read<String>('name') ?? '';
    final isLoggedIn = StorageService.read<bool>('isLoggedIn') ?? false;

    // Calculate profile completion percentage
    double completion = 0.0;
    if (name.isNotEmpty) completion += 40;
    if (profile) completion += 60;
    setState(() {
      profileCompletion = completion;
      status =
          'Profile: ${profile ? "Done" : "Incomplete"}\nStreak: $streak\nCoins: $coins';
    });

    // Manage reminders: only run reminders when user is logged in and profile incomplete
    if (isLoggedIn && completion < 100) {
      await NotificationService().startProfileCompletionReminders();
    } else {
      await NotificationService().stopAllNotifications();
    }
  }

  Future<void> _resetData() async {
    await StorageService.clear();
    setState(() => status = 'Data reset.');
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Stop notifications
    await NotificationService().stopAllNotifications();

    // Set logged out state
    await StorageService.write('isLoggedIn', false);

    // Clear other data but keep login state
    await StorageService.remove('name');
    await StorageService.remove('profile_completed');
    await StorageService.remove('streak');
    await StorageService.remove('coins');

    // Navigate to create account screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Journy'),
            backgroundColor: Theme.of(context).primaryColor,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Progress',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Profile Completion',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${profileCompletion.toInt()}%',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: profileCompletion / 100,
                                backgroundColor: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                                minHeight: 8,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                status,
                                style: const TextStyle(
                                  fontSize: 18,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Actions',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await StreakService.onProfileCompleted();
                              setState(() => status = 'Profile completed!');
                              await _loadData();
                            },
                            icon: const Icon(Icons.person_outline),
                            label: const Text('Complete Profile'),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await StreakService.recordAttempt();
                              await _loadData();
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Attempt Question'),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _resetData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset Data'),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _handleLogout(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Log Out'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[400],
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
