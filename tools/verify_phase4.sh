#!/usr/bin/env bash
# بررسی فاز ۴ روی دستگاهی که Flutter 3.50.1 (FVM) نصب دارد.
set -euo pipefail

cd "$(dirname "$0")/.."

fvm flutter pub get
fvm flutter analyze
fvm flutter test test/features/quick_add_test.dart
fvm flutter test test/features/phase3_state_test.dart
fvm flutter test test/features/onboarding_test.dart
fvm flutter test test/widgets/theme_test.dart
fvm flutter test --update-goldens test/widgets  # در محیط SDK، فایلهای golden ساخته میشوند

echo "فاز ۴ تأیید شد: داشبورد، آنبوردینگ، اعلان و تمها سبز بودند."
