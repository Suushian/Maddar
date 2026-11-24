# 🪐 مدار (Madaar) — Personal Life OS

اپلیکیشن اندرویدی شخصی و آفلاین‑اول برای مدیریت زندگی روزمره: کارها، عادت‌ها، جیب هوشمند و خلوت روزانه — همه در یک داشبورد «امروز» با رابط ۱۰۰٪ فارسی، RTL و تقویم شمسی.

> **وضعیت فعلی:** فاز ۰ (مستندات) و کد فاز ۱ (زیرساخت، RTL، تمها، کمکگیرهای تاریخ و پول، داک و صفحات) پیادهسازی شدند. تأیید نهایی `analyze`/`test` در محیط دارای Flutter SDK باقی است.

---

## نگاه کلی

| ویژگی | تصمیم |
|---|---|
| تجربه | «Native-grade» با Flutter (نه Kotlin بومی) |
| فریمورک | Flutter **3.50.1** (پایدار، پینشده با FVM) — Impeller پیشفرض |
| زبان | Dart (همراه SDK پینشده) |
| State / DI | `flutter_riverpod` + `riverpod_annotation` (Codegen) |
| دیتابیس | Drift + SQLite (`sqlite3_flutter_libs`)، استریم زنده |
| ناوبری | `go_router` + `StatefulShellRoute` |
| طراحی | دو تم Obsidian Dark / Warm Paper، Bento Grid، Glass Dock |
| تاریخ و اعداد | `shamsi_date`، اعداد فارسی، جداکننده سهرقمی |
| فونت | Vazirmatn **v33.003** (OFL‑1.1، باندلشده، بدون اینترنت) |
| حداقل اندروید | API 26 (Android 8.0) |
| خروجی CI | APK release (امضاشده در صورت وجود secrets، در غیر این صورت unsigned) |

---

## مستندات پروژه

| فایل | موضوع |
|---|---|
| [spec کاربر](docs/00-USER_SPEC.md) | بلوپرینت اصلی ارسالشده توسط کاربر (مرجع الزامات، بدون تغییر) |
| [تصمیمات معماری](docs/01-DECISIONS.md) | رفع تمام ابهامات با ADR و دلیل هر انتخاب |
| [معماری فنی](docs/02-ARCHITECTURE.md) | لایهها، پوشهبندی، جریان داده، تست و امنیت |
| [سیستم طراحی](docs/03-DESIGN_SYSTEM.md) | رنگ، تایپوگرافی، هندسه، Motion، کامپوننتها |
| [مدل داده](docs/04-DATA_MODEL.md) | ۷ جدول Drift، ایندکسها، محاسبات و فرمت بکاپ |
| [ماژولها](docs/05-MODULES.md) | رفتار دقیق ۵ ماژول + Quick Add و معیار پذیرش |
| [راهاندازی](docs/06-SETUP.md) | نصب SDK، دستورات روزانه و عیبابیشی |
| [CI/CD](docs/07-CI_CD.md) | GitHub Actions، امضا، Artifact و Release |
| [نقشه راه](docs/08-ROADMAP.md) | فازبندی ۰ تا ۵ با چکلیست و معیار خروج |

---

## شروع سریع (پس از اضافه شدن کد در فاز ۱)

```bash
fvm use 3.50.1
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
fvm flutter analyze
fvm flutter test
fvm flutter run
```

ساخت APK:

```bash
fvm flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

---

## مسیر کار

```
فاز ۰  ✅ مستندات و تصمیمات (همین مرحله)
فاز ۱  🔶 زیرساخت و سیستم طراحی (کد کامل، تأیید SDK باقی)
فاز ۲  ⬜ لایه داده Drift + بکاپ/ریستور
فاز ۳  ⬜ ماژولهای کار، عادت، مالی، ژورنال + Quick Add
فاز ۴  ⬜ داشبورد امروز + پولیش + آنبوردینگ + تنظیمات
فاز ۵  ⬜ CI/CD، تست نهایی و تحویل APK
```

کار در مسیر `arena/83dfb2db-maddar` انجام میشود تا زمانی که کاربر دستور ادامه دهد؛ مرجع `origin/main` روی کامیت `bf0a745` است.

**دستور بعدی پیشنهادی:** «فاز ۲ را شروع کن» (پس از اجرای `bash tools/verify_phase1.sh`).

---

## مجوزها

کد پروژه متعلق به مالک ریپو است. فونت Vazirmatn تحت مجوز **SIL OFL 1.1** است و هنگام باندل شدن در فاز ۱، فایل `OFL.txt` آن در کنار فونتها قرار میگیرد.
