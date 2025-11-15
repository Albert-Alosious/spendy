import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/hive_registry.dart';
import 'models/setting.dart';
import 'screens/add_edit_transaction_screen.dart';
import 'screens/budgets_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lend_borrow_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/transactions_screen.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await registerHiveAdapters();
  await openCoreBoxes();
  final settingsBox = Hive.box<Setting>('settings');
  if (settingsBox.isEmpty) {
    await settingsBox.put(
      'settings',
      Setting(
        id: 'settings',
        currencySymbol: '\$',
        budgetWarningEnabled: true,
        budgetLimitEnabled: true,
        debtReminderDays: 7,
        lastExport: DateTime.now(),
      ),
    );
  }

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const ProviderScope(child: SpendWiserApp()));
}

class SpendWiserApp extends StatefulWidget {
  const SpendWiserApp({super.key});

  @override
  State<SpendWiserApp> createState() => _SpendWiserAppState();
}

class _SpendWiserAppState extends State<SpendWiserApp> {
  int _selectedIndex = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    AddEditTransactionScreen(),
    BudgetsScreen(),
    LendBorrowScreen(),
    SettingsScreen(),
  ];

  static const _labels = [
    'Home',
    'Transactions',
    'Add',
    'Budgets',
    'Lend/Borrow',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendWiser',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Scaffold(
        body: SafeArea(child: _screens[_selectedIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          items: List.generate(_labels.length, (index) {
            return BottomNavigationBarItem(
              icon: Icon(_iconForIndex(index)),
              label: _labels[index],
            );
          }),
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }

  IconData _iconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.list;
      case 2:
        return Icons.add;
      case 3:
        return Icons.pie_chart;
      case 4:
        return Icons.handshake;
      case 5:
        return Icons.settings;
      default:
        return Icons.circle;
    }
  }
}
