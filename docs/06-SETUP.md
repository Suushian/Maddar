# ⚙️ راهاندازی محیط توسعه

## ۱. پیشنیازها

| ابزار | نسخه | توضیح |
|---|---|---|
| Flutter SDK | **3.50.1** (پینشده در `.fvmrc`) | کانال stable |
| FVM | آخرین نسخه | `dart pub global activate fvm` |
| Dart | همراه SDK پینشده | نسخه دقیق با `fvm flutter --version` ثبت میشود |
| JDK | 17 (Temurin توصیهشده) | برای Gradle اندروید |
| Android SDK | API 26+ نصبشده | `flutter doctor -v` باید سبز باشد |
| Git / gh | آخرین نسخه | احرازشده بهعنوان Suushian، دسترسی ADMIN |

## ۲. نصب و اجرا

```bash
# ۱. نصب نسخه پینشده
fvm install
fvm use 3.50.1

# ۲. وابستگیها و تولید کد
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs

# ۳. بررسی سلامت
fvm flutter doctor -v
fvm flutter analyze
fvm flutter test

# ۴. اجرا
fvm flutter run
```

در صورتی که FVM در دسترس نیست، میتوان از `flutter` سیستم هم استفاده کرد، ولی مسئول تطابق نسخه با `.fvmrc` بر عهده توسعهدهنده است. CI همیشه از `.fvmrc` پیروی میکند.

## ۳. دستورات روزانه

| کار | دستور |
|---|---|
| تغییر مدلها/پرووایدرها | `fvm dart run build_runner watch --delete-conflicting-outputs` |
| آنالیز | `fvm flutter analyze` |
| تست | `fvm flutter test --coverage` |
| فرمت | `fvm dart format .` |
| بیلد APK | `fvm flutter build apk --release --obfuscate --split-debug-info=build/debug-info` |
| بیلد appbundle | `fvm flutter build appbundle --release` |
| لیست دستگاهها | `fvm flutter devices` |

## ۴. ساختار فایلهایی که در فاز ۱ ایجاد میشود

```text
pubspec.yaml
analysis_options.yaml
lib/main.dart
lib/app.dart
lib/core/theme/{app_colors,app_typography,app_theme}.dart
lib/core/utils/{jalali_helper,currency_formatter,haptics}.dart
lib/core/router/app_router.dart
lib/core/widgets/{bento_card,floating_glass_dock,empty_state_view}.dart
assets/fonts/vazirmatn/*.ttf + OFL.txt
test/core/utils/jalali_helper_test.dart
test/core/utils/currency_formatter_test.dart
.fvmrc
```

## ۵. نکات اندروید

- `minSdkVersion 26`، `targetSdkVersion` مطابق قالب Flutter 3.50.1.
- مجوزهای موردنیاز: `POST_NOTIFICATIONS` (اندروید ۱۳+)، `USE_BIOMETRIC` (اختیاری)، `SCHEDULE_EXACT_ALARM` (فقط در صورت انتخاب یادآور دقیق).
- `android/key.properties` و فایل keystore **هرگز کامیت نشوند**؛ الگوی `.gitignore` در فاز ۱ اضافه میشود.
- Impeller در نسخه پینشده پیشفرض است؛ آن را غیرفعال نکنید.

## ۶. عیبابیشی رایج

| مشکل | راهحل |
|---|---|
| `build_runner` خطای Conflicting outputs | `--delete-conflicting-outputs` را اضافه کنید |
| فونت فارسی نشان داده نمیشود | مسیر family در `pubspec.yaml` و `fontFamily` در تم را چک کنید |
| تاریخ اشتباه نمایش داده میشود | مطمئن شوید `date_key` میلادی است و تبدیل فقط در لایه نمایش است |
| `flutter doctor` Android SDK را نیافت | `ANDROID_HOME` و `ANDROID_AVD_HOME` را تنظیم کنید |
| CI نسخه متفاوتی دارد | `.fvmrc` را به عنوان تنها مرجع نسخه نگه دارید |

---

## ۷. وضعیت مخزن

- برنچ کاری: `arena/83dfb2db-maddar` (فعال، clean).
- مرجع: `origin/main` @ `bf0a745`.
- برنچ فعلی upstream ندارد؛ هنگام ارسال: `git push -u origin arena/83dfb2db-maddar`.
- هیچ Pull Request و workflowای تاکنون وجود نداشته است.
