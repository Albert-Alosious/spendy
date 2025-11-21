import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/hive_registry.dart';
import 'models/setting.dart';
import 'screens/budgets_screen.dart';
import 'screens/home_screen.dart';
import 'screens/lend_borrow_screen.dart';
import 'screens/transactions_screen.dart';
import 'services/notification_service.dart';
import 'screens/add_edit_transaction_screen.dart';
import 'utils/app_theme.dart';

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
        currencySymbol: '₹',
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

class SpendWiserApp extends ConsumerStatefulWidget {
  const SpendWiserApp({super.key});

  @override
  ConsumerState<SpendWiserApp> createState() => _SpendWiserAppState();
}

class _SpendWiserAppState extends ConsumerState<SpendWiserApp> {
  int _navIndex = 0;
  int _contentIndex = 0;

  static const _contentScreens = <Widget>[
    HomeScreen(),
    TransactionsScreen(),
    BudgetsScreen(),
    LendBorrowScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SpendWiser',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: Scaffold(
        backgroundColor: AppTheme.dark.scaffoldBackgroundColor,
        body: IndexedStack(
          index: _contentIndex,
          children: _contentScreens,
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _navIndex,
            onTap: (index) => _onNavTap(context, index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.accentTeal,
            unselectedItemColor: const Color.fromARGB(179, 168, 166, 166),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded), label: 'Home'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_rounded),
                  label: 'Transactions'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.pie_chart_rounded), label: 'Budgets'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.handshake_rounded), label: 'Lend/Borrow'),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onNavTap(BuildContext context, int index) async {
    setState(() {
      _navIndex = index;
      _contentIndex = index;
    });
  }
}
