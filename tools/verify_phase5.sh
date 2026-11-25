#!/usr/bin/env bash
# بررسی نهایی فاز ۵ قبل از تگ زدن.
set -euo pipefail

cd "$(dirname "$0")/.."

echo "1) بررسی سینتکس Dart"
node /tmp/dart-parse2/parse.js lib test

echo "2) بررسی YAML ورکفلو"
python3 - <<'PY'
import yaml
with open('.github/workflows/build-android-apk.yml', encoding='utf-8') as fh:
    data = yaml.safe_load(fh)
assert set(data['jobs']) == {'build', 'release'}, data['jobs'].keys()
print('workflow yaml ok')
PY

echo "3) بررسی عدم وجود TODO در کد"
if grep -RIn 'TODO\|FIXME' lib android/app/build.gradle.kts; then
  echo 'TODO باقی مانده است' >&2
  exit 1
fi

echo "4) بیلد و تست کامل (نیازمند Flutter SDK)"
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter analyze
fvm flutter test
fvm flutter build apk --release --obfuscate --split-debug-info=build/debug-info

echo "فاز ۵ تأیید شد: ورکفلو معتبر و APK قابل تحویل است."
