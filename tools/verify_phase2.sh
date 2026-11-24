#!/usr/bin/env bash
# بررسی فاز ۲ روی دستگاهی که Flutter 3.50.1 (FVM) نصب دارد.
set -euo pipefail

cd "$(dirname "$0")/.."

fvm flutter pub get
fvm flutter analyze
fvm flutter test test/core/database/database_test.dart
fvm flutter test test/core/utils/calculators_test.dart

echo "فاز ۲ تأیید شد: اسکیما، تراکنشها، بکاپ و محاسبات سبز بودند."
