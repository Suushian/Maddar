# 🗺 نقشه راه اجرا (Phased Plan)

> ترتیب فازها الزامی است و با [`spec کاربر`](00-USER_SPEC.md) مطابقت دارد، با این تفاوت که **فاز ۰** برای مستندسازی و رفع ابهامات اضافه شده است. هر فاز تنها زمانی تمام میشود که معیار خروج آن سبز باشد.

## وضعیت کلی

| فاز | نام | وضعیت | وابسته به |
|---|---|---|---|
| ۰ | مستندات و تصمیمات | ✅ تکمیل | — |
| ۱ | زیرساخت و سیستم طراحی | 🔶 کد کامل، تأیید SDK باقی | فاز ۰ |
| ۲ | لایه داده و بکاپ | ✅ کد کامل، تأیید SDK باقی | فاز ۱ |
| ۳ | ماژولهای عملیاتی + Quick Add | ✅ کد کامل، تأیید SDK باقی | فاز ۲ |
| ۴ | داشبورد امروز و پولیش | 🔶 کد کامل، golden و تأیید SDK باقی | فاز ۳ |
| ۵ | CI/CD و تحویل | ⬜ | فاز ۴ |

---

## فاز ۰ — مستندات و تصمیمات ✅

**هدف:** رفع تمام ابهامات قبل از نوشتن کد و قفل کردن مرجع پیادهسازی.

- [x] مطالعه کامل سند ۹بخش کاربر
- [x] بررسی اتصال ریپو، remote، احراز هویت و وضعیت برنچ
- [x] نوشتن ۱۶ ADR و تعیین تکلیف تناقضها
- [x] نوشتن معماری، طراحی، مدل داده، ماژولها، setup و CI
- [x] فازبندی و معیار پذیرش هر فاز

**معیار خروج:** مستندات قابل خواندناند، تصمیمها متناقض نیستند، دستور شروع فاز ۱ مشخص است.

---

## فاز ۱ — زیرساخت و سیستم طراحی

**هدف:** اسکلت Flutter قابل اجرا با RTL فارسی و هویت بصری کامل، بدون هیچ منطق تجاری.

### کارها

- [x] اسکلت معادل `flutter create` در ریشه ریپو (org `ir.madaar`، project `madaar`)
- [x] ایجاد `.fvmrc` و قفل Flutter 3.50.1، تنظیم `minSdk 26`
- [x] `pubspec.yaml` با وابستگیها: riverpod + annotations + generator، drift + drift_dev + sqlite3_flutter_libs + path_provider، go_router، shamsi_date، intl، lucide_icons_flutter، fl_chart، flutter_animate، flutter_local_notifications، local_auth، file_picker، share_plus
- [x] باندل ۵ فونت Vazirmatn v33.003 + `OFL.txt` (از مخزن رسمی)
- [x] `AppColors`، `AppTypography`، `AppTheme` براساس [`03-DESIGN_SYSTEM.md`](03-DESIGN_SYSTEM.md)
- [x] `JalaliHelper` + `CurrencyFormatter` + `Haptics` با تست unit
- [x] `Directionality.rtl`، لوکال `fa_IR`، اعداد فارسی و `tabularFigures`
- [x] `GoRouter` + `StatefulShellRoute` با ۵ مسیر و حفظ state تبها
- [x] `BentoCard`، `FloatingGlassDock` (۵ تب + `+`)، `EmptyStateView`
- [x] صفحات اسکلت خالی (بدون داده ساختگی) برای ۵ ماژول
- [x] `.gitignore` شامل `key.properties`، `*.jks`، `build/`، `.fvm/`، فایلهای generated ناسازگار
- [x] `analysis_options.yaml` با قواعد سختگیرانه (اجرای analyze در محیط SDK باقی است)

### معیار خروج

- `fvm flutter run` روی emulator/device اندروید اجرا میشود.
- تمام متنها فارسی و RTLاند؛ تاریخ و اعداد شمسی/فارسی نمایش داده میشوند.
- جابهجایی تبها scroll و state را حفظ میکند.
- `flutter analyze` و `flutter test` بدون خطا.

> **وضعیت اجرا (۲۰۲۶‑۱۱‑۲۴):** تمام موارد فاز ۱ پیادهسازی شدند. چون Flutter SDK و pub.dev در محیط اجرا در دسترس نبودند، آنالیز و تست اجرا نشدند؛ پیش از شروع فاز ۲، دستور `bash tools/verify_phase1.sh` را در محیط مجهز اجرا کنید.

---

## فاز ۲ — لایه داده و بکاپ

**هدف:** ۷ جدول Drift، Repositoryها، استریمها و بکاپ JSON.

### کارها

- [x] تعریف ۷ جدول مطابق [`04-DATA_MODEL.md`](04-DATA_MODEL.md) (شامل `focus_date`، `repeat_type`، `due_day`)
- [x] `AppDatabase` + `MigrationStrategy` + `foreign_keys = ON`
- [x] اعمال CHECK و UNIQUE و ایندکسها؛ تست Migration v1
- [x] DAOs و Repositoryها با متدهای تراکنشی:
  - `setTopFocus` با محدودیت ۳
  - `toggleHabitLog` (upsert)
  - `addTransaction`, `markBillPaid`
  - `upsertJournal`
- [x] Riverpod StreamProviders و `todaySummaryProvider`
- [x] منطق pure: `StreakCalculator`، `BudgetCalculator`، `RepeatRuleMatcher` + تست
- [x] `BackupService`: export JSON نسخهدار، import اعتبارسنجیشده با اسنپشات
- [x] `SettingsRepository` تک ردیف و onboarding flag
- [x] تستRepositoryها با in-memory SQLite (جداول واقعی، نه mockها)

### معیار خروج

- تمام استریمها هنگام تغییر داده بهروز میشوند.
- چهارمین تلاش تمرکز، رد میشود و داده دستنخورده میماند.
- بکاپ → ریست → بازیابی، تمام ۷ جدول را باز میگرداند.
- تست migration و محاسبات سبز.

> **وضعیت اجرا (۲۰۲۶‑۱۱‑۲۴):** تمام موارد فاز ۲ پیادهسازی شدند. جزئیات تفاوت پیادهسازی (SQL خام Drift بهجای codegen) در [`PHASE2_NOTES.md`](PHASE2_NOTES.md) است. اجرای `flutter test` در محیط دارای SDK باقی است.

---

## فاز ۳ — ماژولهای عملیاتی و Quick Add

**هدف:** چهار ماژول کامل مطابق [`05-MODULES.md`](05-MODULES.md).

### کارها

- [x] **Tasks:** ۳ تب، ۴ حوزه، star/snooze/swipe + undo 5 ثانیه
- [x] **Habits:** تعریف عادت (daily/weekly/alternate)، Heatmap 30/90، streakها، اصلاح روزهای گذشته
- [x] **Finance:** کیپد اختیاری، دستهبندیها، بودجه و Safe-to-Spend، Donut chart، قبوض اقساط
- [x] **Journal:** Mood 1–5، Energy 1–5، Context Tags، میکروژورنال، نمودار خطی
- [x] **Universal Quick Add:** شیت ۴تبه با تب پیشفرض متناسب مسیر، `rootNavigator: true`
- [x] EmptyStateها، Haptics، خطاهای دوستانه
- [x] تست widget برای Quick Add و فرمها

### معیار خروج

- هر عملیات ثبت با حداکثر ۳ لمس از Quick Add تمام میشود.
- تمام معیار پذیرش چهار ماژول در [`05-MODULES.md`](05-MODULES.md) تیک خوردهاند.
- اعداد، دستهبندیها و چارتهای مالی با داده واقعی Drift تغذیه میشوند.

> **وضعیت اجرا (۲۰۲۶‑۱۱‑۲۴):** تمام موارد فاز ۳ پیادهسازی شدند. جزئیات و محدودیتهای تأییدSDK در [`PHASE3_NOTES.md`](PHASE3_NOTES.md) است. اجرای `bash tools/verify_phase3.sh` در محیط دارای SDK باقی است.

---

## فاز ۴ — داشبورد امروز و پولیش

**هدف:** اتصال تمام ماژولها به خانه، تجربه بصری نهایی و onboarding.

### کارها

- [x] هدر هوشمند + ProgressRing ترکیبی
- [x] کارت ۳ تمرکز طلایی با تیک مستقیم
- [x] نوار عادتهای امروز + streak
- [x] دو کارت دوقلوی جیب و حالوهوا
- [x] انیمیشن Staggered و Spring با `flutter_animate` + reduced motion
- [x] Haptic Feedback در تمام تیکها و ذخیرهها
- [x] آنبوردینگ ۳۰ ثانیهای (نام، بودجه، تم/یادآور)
- [x] صفحه تنظیمات کامل + بکاپ/بازیابی + ریست دو مرحلهای
- [x] اعلان محلی یادآور ژورنال و یادآور کارها + مجوز Android 13+
- [x] قفل بیومتریک اختیاری
- [x] تست widget برای onboarding، تم و reduced motion
- [ ] golden test تاریک/روشن (تولید فایلها نیازمند SDK است)

### معیار خروج

- تغییر از هر ماژول در خانه بدون refresh و در ≤ ۱ فریم دیده میشود.
- onboarding فقط بار اول نمایش داده میشود.
- تمها و انیمیشنها در reduced motion بهدرستی رفتار میکنند.

> **وضعیت اجرا (۲۰۲۶‑۱۱‑۲۵):** کد فاز ۴ پیادهسازی شد. جزئیات در [`PHASE4_NOTES.md`](PHASE4_NOTES.md) است. goldenها و تأیید نهایی SDK در محیط دارای Flutter باقیاند.

---

## فاز ۵ — تحویل و CI/CD

**هدف:** بیلد خودکار و انتشار APK.

### کارها

- [ ] `.github/workflows/build-android-apk.yml` مطابق [`07-CI_CD.md`](07-CI_CD.md)
- [ ] مسیر امضاشده (secretها) و مسیر unsigned (fallback)
- [ ] آپلود Artifact + SHA‑256
- [ ] انتشار Release بر روی تگ `v*`
- [ ] تست کامل بیلد با `--obfuscate --split-debug-info`
- [ ] بهروزرسانی README با لینک Release و نسخه نهایی
- [ ] بررسی نهایی: analyze، test، diff، مستندات

### معیار خروج

- بیلد با push به `main` سبز و APK قابل نصب است.
- Release فقط در حالت امضاشده منتشر میشود.
- تمام چکلیستهای فازهای ۱ تا ۴ تیک خوردهاند.

---

## Definition of Done عمومی

1. `flutter analyze` بدون warning و `flutter test` سبز.
2. هیچ Placeholder، TODO بدون تیکت، یا داده ساختگی در محصول باقی نماند.
3. RTL، فونت و اعداد فارسی در تمام صفحات رعایت شود.
4. هیچ عملیات محلی اسپینر یا تأخیر قابل مشاهده نداشته باشد.
5. data کاربر تنها در دستگاه بماند و بکاپ فقط با اقدام صریح اشتراکگذاری شود.
6. مستندات مربوط به فاز بهروزرسانی شوند.

---

## دستور بعدی

پس از تأیید کاربر، دستور اجرا بهصورت زیر است:

> **«فاز ۵ را شروع کن»**

در آن مرحله پیادهسازی دقیقاً از چکلیست فاز ۵ آغاز میشود و پیشرفت در همین فایل تیک زده میشود.
