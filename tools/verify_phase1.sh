#!/usr/bin/env bash
# اجرای بررسیهای فاز ۱ روی دستگاهی که Flutter 3.50.1 (FVM) نصب دارد.
set -euo pipefail

cd "$(dirname "$0")/.."

fvm flutter --version
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter build apk --debug

echo "فاز ۱ تأیید شد: analyze، test و بیلد debug سبز بودند."
