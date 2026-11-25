# فاز ۵ — CI/CD و تحویل APK

ورکفلوی تحویل و مسیر امضای فاز ۵ در این سند خلاصه شدهاند.

## ورکفلو

فایل: `.github/workflows/build-android-apk.yml`

### رویدادها

- `push` به `main` → analyze، test و بیلد APK + Artifact.
- `workflow_dispatch` → بیلد دستی همانند push.
- `push` با تگ `v*` → همان مراحل + انتشار Release **فقط در حالت امضاشده**.

### مراحل

1. Checkout با `fetch-depth: 0`.
2. خواندن نسخه Flutter از `.fvmrc` و نصب همان نسخه (`subosito/flutter-action`).
3. JDK 17 (Temurin)، کش pub/Gradle و `flutter doctor -v`.
4. `flutter pub get` → `dart run build_runner build --delete-conflicting-outputs`.
5. `flutter analyze` و `flutter test` — هر خطا بیلد را متوقف میکند.
6. آمادهسازی امضا از Secrets یا fallback unsigned.
7. بیلد:
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/debug-info
   ```
8. تغییر نام به `madaar-release.apk` یا `madaar-release-unsigned.apk`، محاسبه SHA‑256 و آپلود Artifact `madaar-apk`.
9. job جداگانه release فقط برای تگ `v*` وفقط در حالت امضاشده، با `gh release create/upload`.

## امضا

چهار Secret لازم:

| Secret | محتوا |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | محتوای base64 فایل `.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | رمز keystore |
| `ANDROID_KEY_ALIAS` | alias کلید |
| `ANDROID_KEY_PASSWORD` | رمز کلید |

اگر هر چهار موجود باشند، workflow فایل `android/app/release-key.jks` و `android/key.properties` را ایجاد میکند و `android/app/build.gradle.kts` از `signingConfig("release")` استفاده میکند. در نبود آنها هشدار چاپ میشود و بیلد با کلید debug بهعنوان **unsigned** فقط Artifact میشود.

کلیدها و `key.properties` توسط `.gitignore` پوشانده میشوند و وارد ریپو نمیشوند.

## تغییرات کد

- `android/app/build.gradle.kts`: حذف کامنت TODO قالب و اضافه شدن signingConfig مشروط بر اساس `android/key.properties`.
- `README.md`: لینک «آخرین نسخه» به GitHub Releases و وضعیت فاز ۵.
- `docs/08-ROADMAP.md`: چکلیست فاز ۵ بهروز شد.

## بررسیهای قابل اجرا در محیط فعلی

- اعتبارسنجی YAML ورکفلو: موفق (پارس شد؛ ۲ job و ۱۶ step).
- پارسر Dart: ۴۸ فایل، ۰ خطای سینتکس.
- تعادل براکتهای `build.gradle.kts`: برقرار.

## باقیمانده

اجرای واقعی GitHub Actions وابسته به محیط GitHub و تنظیم Secrets است. در این sandbox امکان اجرای `flutter build apk` وجود ندارد. پس از push به `main` میتوان نتیجه را در تب Actions مشاهده کرد.

برای انتشار امضاشده:

```bash
git tag v1.0.0
git push origin v1.0.0
```

در نبود Secrets، Release ساخته نمیشود و تنها Artifact unsigned در job بیلد قابل دانلود است.
