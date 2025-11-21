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
      theme: AppTheme.light,
      home: Scaffold(
        backgroundColor: AppTheme.light.scaffoldBackgroundColor,
        body: IndexedStack(
          index: _contentIndex,
          children: _contentScreens,
        ),
        bottomNavigationBar: _buildBottomNav(context),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurface.withOpacity(0.5),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_rounded), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_rounded, size: 32), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_rounded), label: 'Budgets'),
          BottomNavigationBarItem(icon: Icon(Icons.handshake_rounded), label: 'Lend/Borrow'),
        ],
      ),
    );
  }

  Future<void> _onNavTap(BuildContext context, int index) async {
    if (index == 2) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
      );
      return;
    }
    setState(() {
      _navIndex = index;
      _contentIndex = index > 2 ? index - 1 : index;
    });
  }
}
