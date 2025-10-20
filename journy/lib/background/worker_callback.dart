import 'package:workmanager/workmanager.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import '../services/streak_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await StorageService.init();
    await NotificationService().init();

    await StreakService.checkEndOfDayReminder();
    await StreakService.checkMissedStreakReminder();
    await StreakService.checkSevenDayStreakReward();
    return Future.value(true);
  });
}
