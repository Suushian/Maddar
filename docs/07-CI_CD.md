# 🚀 CI/CD و ساخت APK

> ورکفلو در فاز ۵ در مسیر `.github/workflows/build-android-apk.yml` ایجاد میشود. این فایل مشخصات دقیق آن است.

## ۱. رویدادها

- `push` به `main` → بیلد + Artifact.
- `workflow_dispatch` → بیلد دستی.
- `push` با تگ `v*` → بیلد + Artifact + **GitHub Release** (فقط در صورت امضاشده بودن APK).

## ۲. مراحل ورکفلو

1. `actions/checkout@v4` (با `fetch-depth: 0`).
2. نصب JDK 17 (`actions/setup-java@v4`, distribution `temurin`).
3. نصب Flutter توسط `subosito/flutter-action@v2` با خواندن نسخه از `.fvmrc` (یا `fvm install` سپس `fvm flutter`).
4. کش: `~/.pub-cache`، `~/.gradle/caches`، `~/.gradle/wrapper`.
5. اجزای Android SDK و `flutter doctor`.
6. `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs`.
7. `flutter analyze` → `flutter test` (هر خطا Pipeline را متوقف میکند).
8. آمادهسازی امضا (بخش ۳).
9. `flutter build apk --release --obfuscate --split-debug-info=build/debug-info`.
10. تغییر نام خروجی به `madaar-release.apk` یا `madaar-release-unsigned.apk`، محاسبه SHA‑256، آپلود Artifact.
11. در صورت تگ `v*` و وجود امضا، ایجاد/بهروزرسانی Release با فایل APK و فایل `.sha256` آن.

## ۳. امضا (ADR‑010)

### Secretهای موردنیاز

| Secret | محتوا |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | محتوای فایل `.jks` به base64 |
| `ANDROID_KEYSTORE_PASSWORD` | رمز keystore |
| `ANDROID_KEY_ALIAS` | نام alias کلید |
| `ANDROID_KEY_PASSWORD` | رمز کلید |

### رفتار

- اگر هر چهار Secret موجود باشند: مرحله مربوطه فایل `android/app/release-key.jks` و `android/key.properties` را ایجاد میکند، بیلد **امضاشده** است و نام خروجی `madaar-release.apk` میباشد.
- در نبود آنها: ورکفلوی هشدار چاپ میکند، بیلد **unsigned** میشود و خروجی `madaar-release-unsigned.apk` فقط بهعنوان Artifact آپلود میشود.
- انتشار Release بدون امضا **ممنوع** است؛ ورکفلوی در این حالت Release را ایجاد نمیکند.
- کلیدها و `key.properties` هرگز در ریپو ذخیره نمیشوند و توسط `.gitignore` پوشانده میشوند.

### ایجاد keystore (یکبار، توسط مالک ریپو)

```bash
keytool -genkey -v -keystore madaar-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias madaar
base64 -w0 madaar-release.jks   # محتوا را در Secret قرار دهید
```

> توکن GH فعلی اجازه خواندن لیست Secrets را از طریق API ندارد (403). بنابراین وجود یا نبود secrets فعلاً تأیید نشده است و رفتار fallback الزامی است.

## ۴. نامها و خروجیها

| مورد | مقدار |
|---|---|
| Artifact | `madaar-apk` (شامل APK + فایل `.sha256`) |
| APK امضاشده | `madaar-release.apk` |
| APK امضانشده | `madaar-release-unsigned.apk` |
| Debug info | `build/debug-info` (برای de-obfuscation) |
| نمونه تگ | `v1.0.0` |

## ۵. کیفیت و امنیت

- `permissions: contents: read` پیشفرض؛ برای انتشار Release: `contents: write` فقط در job مربوطه.
- از اجرای اسکریپتهای خارجی غیر از منابع رسمی پرهیز میشود.
- هیچ Secretی در لاگ چاپ نمیشود؛ Secretها فقط بهعنوان env به مرحله امضا پاس داده میشوند.
- بیلد با `--obfuscate` و `--split-debug-info` تولید میشود؛ debug-info به Release اضافه نمیشود.

## ۶. تعریف تمامشده فاز ۵

- [ ] ورکفلوی با push به `main` سبز میشود.
- [ ] `flutter analyze` و `flutter test` در CI بدون خطا اجرا میشوند.
- [ ] Artifact حاوی APK و فایل `.sha256` است.
- [ ] مسیر امضاشده (با secrets) و مسیر unsigned (بدون secrets) هر دو تست شدهاند.
- [ ] تگ `v*` منجر به Release میشود (در حالت امضاشده).
- [ ] README لینک دانلود آخرین Release را دارد.
