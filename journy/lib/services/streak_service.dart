import 'package:intl/intl.dart';
import 'notification_service.dart';
import 'storage_service.dart';

class StreakService {
  static final _ns = NotificationService();

  static String _today() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  static Future<void> onSignUp() async {
    await StorageService.write(
      'signed_up_at',
      DateTime.now().toIso8601String(),
    );
    await StorageService.write('profile_completed', false);

    // Schedule profile reminders
    await _ns.showInstant(
      id: 100,
      title: 'Welcome to Journy!',
      body: 'Start your journey by completing your profile.',
    );

    Future.delayed(const Duration(minutes: 30), () {
      _ns.showInstant(
        id: 101,
        title: 'Complete your profile',
        body: 'Complete your profile and unlock MemoCoins.',
      );
    });

    Future.delayed(const Duration(hours: 24), () {
      _ns.showInstant(
        id: 102,
        title: 'Final reminder',
        body: 'Final reminder: Complete your profile and earn 25 MemoCoins.',
      );
    });
  }

  static Future<void> onProfileCompleted() async {
    await StorageService.write('profile_completed', true);
    // Stop any profile-completion reminders (including recurring ones)
    await _ns.stopAllNotifications();

    // Optional: show a confirmation notification that profile is completed
    await _ns.showInstant(
      id: 103,
      title: 'Profile completed',
      body: 'Thanks! Your profile is now complete.',
    );
  }

  static Future<void> recordAttempt() async {
    final today = _today();
    final last = StorageService.read<String>('last_attempt_date') ?? '';

    if (last != today) {
      await StorageService.write('last_attempt_date', today);

      int streak = StorageService.read<int>('streak') ?? 0;
      final yesterday = DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.now().subtract(const Duration(days: 1)));

      if (last == yesterday)
        streak++;
      else
        streak = 1;

      await StorageService.write('streak', streak);

      if (streak == 7) {
        int coins = StorageService.read<int>('coins') ?? 0;
        coins += 10;
        await StorageService.write('coins', coins);
        await _ns.showInstant(
          id: 2000,
          title: '■ 7-day streak!',
          body: '■ 7-day streak! +10 MemoCoins.',
        );
      }
    }
  }

  static Future<void> checkEndOfDayReminder() async {
    final today = _today();
    final last = StorageService.read<String>('last_attempt_date') ?? '';
    if (last != today) {
      // Schedule notification for 9:30 PM today
      await _ns.scheduleDaily(
        id: 3001,
        title: 'Keep your streak alive',
        body: 'Keep your streak alive—attempt 1 quick question.',
        hour: 21,
        minute: 30,
      );
    }
  }

  static Future<void> checkMissedStreakReminder() async {
    final yesterday = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.now().subtract(const Duration(days: 1)));
    final last = StorageService.read<String>('last_attempt_date') ?? '';
    if (last != yesterday) {
      // Schedule notification for 9:00 AM next morning
      await _ns.scheduleDaily(
        id: 3002,
        title: 'You missed yesterday!',
        body: 'You missed yesterday. Restart your streak today.',
        hour: 9,
        minute: 0,
      );
    }
  }

  static Future<void> checkSevenDayStreakReward() async {
    final streak = StorageService.read<int>('streak') ?? 0;
    if (streak >= 7) {
      await _ns.showInstant(
        id: 4000,
        title: '🔥 7-Day Streak!',
        body: 'Keep it going! You earned +10 MemoCoins!',
      );
    }
  }
}
