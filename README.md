# Spendy – Offline Personal Finance

Spendy is an offline-first personal finance app built with Flutter, Riverpod, and Hive. It helps you log expenses/income, track monthly budgets by category, and manage lending/borrowing without any cloud dependency.

## Features
- **Dashboards:** Monthly income, spend, net, budget alerts, category spend pie, debt summary, and quick category shortcuts.
- **Transactions:** Filter by type/date/category/account, search notes, add/edit with custom categories and saving bucket, debt linking, and live category dropdowns.
- **Budgets:** Per-category monthly budgets with progress, alerts, edit/delete, and backfill of existing expenses when a budget is created.
- **Lend/Borrow:** Track debts (lend/borrow), due dates, repayments, and statuses.
- **History:** Prior-month summaries (income/spend/net).
- **Settings:** Currency symbol and notification channel for budget alerts.
- **Categories:** Default set plus “Saving”; custom categories persist and appear everywhere without restart.

## Tech Stack
- Flutter 3.x, Dart 3.x
- State: Riverpod
- Storage: Hive (offline, no cloud)
- Charts: fl_chart
- Notifications: flutter_local_notifications

## Setup
```bash
flutter pub get
```

## Run
```bash
flutter run
```

## Build
```bash
flutter build apk --release           # Android APK
flutter build appbundle --release     # Play Store bundle
```

## Tests
```bash
flutter test
```

## Icons
Launcher icon config points to `assest/icons/app_icon.png` (update `pubspec.yaml` if you move it). Generate with:
```bash
flutter pub run flutter_launcher_icons
```

## Notes
- Package/bundle IDs use `com.example.spendy` by default; update for production signing.
- All data is local (Hive boxes). Back up device storage if needed. 

## License
This project is licensed under the MIT License. See `LICENSE` for details.
