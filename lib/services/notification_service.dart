import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/category_budget.dart';
import '../models/debt.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final settings = InitializationSettings(android: androidSettings);
    await _plugin.initialize(settings);
  }

  Future<void> maybeNotifyBudgetThreshold(CategoryBudget budget) async {
    if (budget.limit <= 0) return;
    final percent = budget.spent / budget.limit;
    final isWarning = percent >= budget.warningThreshold;
    if (isWarning && percent < 1.0) {
      await _showNotification(
        id: budget.id.hashCode,
        title: 'Budget approaching limit',
        body: 'You have used ${(percent * 100).toStringAsFixed(0)}% of ${budget.categoryId}',
      );
    } else if (percent >= 1.0) {
      await _showNotification(
        id: budget.id.hashCode + 1,
        title: 'Budget limit reached',
        body: 'You exceeded ${budget.categoryId} budget of ${budget.limit}',
      );
    }
  }

  Future<void> notifyDebtDue(Debt debt) async {
    if (debt.dueDate == null) return;
    await _showNotification(
      id: debt.id.hashCode,
      title: 'Debt reminder',
      body: 'Debt for ${debt.personId} is due on ${debt.dueDate}',
    );
  }

  Future<void> _showNotification({required int id, required String title, required String body}) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails('spend_wiser', 'SpendWiser Alerts', importance: Importance.defaultImportance),
    );
    await _plugin.show(id, title, body, details);
  }
}
