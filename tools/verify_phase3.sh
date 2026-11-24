#!/usr/bin/env bash
# بررسی فاز ۳ روی دستگاهی که Flutter 3.50.1 (FVM) نصب دارد.
set -euo pipefail

cd "$(dirname "$0")/.."

fvm flutter pub get
fvm flutter analyze
fvm flutter test test/core/database/database_test.dart
fvm flutter test test/core/utils/calculators_test.dart
fvm flutter test test/features/quick_add_test.dart
fvm flutter test test/features/phase3_state_test.dart

echo "فاز ۳ تأیید شد: ماژولها، Quick Add و استریمها سبز بودند."
