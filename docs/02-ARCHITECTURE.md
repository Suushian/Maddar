# 🏗 معماری فنی مدار

> این ساختار **پس از اعمال تصمیمات** [`01-DECISIONS.md`](01-DECISIONS.md) نوشته شده است و مرجع پیادهسازی است.

## ۱. لایهها و قاعده وابستگی

```
Presentation (features/*/presentation)
        ↓  فقط میخواند و فراخوانی میکند
Application (features/*/application — Providers / UseCases)
        ↓
Domain (features/*/domain — Entities / Pure logic)
        ↓
Data (core/database + features/*/data — Drift DAOs / Repositories)
```

- ویجتها **هیچگاه** مستقیماً Drift را صدا نمیزنند؛ تنها از Riverpod Providerها استفاده میکنند.
- منطق خالص (Jalali، Streak، Budgets، Currency) در `core/utils` یا `domain` قرار دارد و unit-test میشود.
- وابستگیها با `@provider` / `riverpod_annotation` تزریق میشوند؛ Singleton دستساز ممنوع است.
- تمام استریمها از Drift `watch()` میآیند؛ رابط کاربری به Flows واکنش نشان میدهد و نیاز به refresh دستی ندارد.

## ۲. ساختار پوشهها (ریشه ریپو)

```text
Maddar/
├── .fvmrc                         # Flutter 3.50.1
├── .github/workflows/
│   └── build-android-apk.yml
├── assets/
│   ├── fonts/vazirmatn/           # 5 TTF + OFL.txt
│   └── images/                    # آیکونها/نمادها (در صورت نیاز)
├── android/                       # توسط flutter create، minSdk 26
├── lib/
│   ├── main.dart                  # ProviderScope + FVM-generated bootstrap
│   ├── app.dart                   # MaterialApp.router، تمها، RTL fa_IR
│   ├── core/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── tables/            # 7 جدول
│   │   │   └── migrations/        # MigrationStrategy + تستها
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   └── app_theme.dart
│   │   ├── utils/
│   │   │   ├── jalali_helper.dart
│   │   │   ├── currency_formatter.dart
│   │   │   ├── streak_calculator.dart
│   │   │   ├── budget_calculator.dart
│   │   │   └── haptics.dart
│   │   ├── router/app_router.dart
│   │   ├── services/              # notifications, biometric, backup, share
│   │   └── widgets/               # BentoCard, FloatingGlassDock, QuickAdd, EmptyState
│   └── features/
│       ├── onboarding/
│       ├── today/
│       ├── tasks/
│       ├── habits/
│       ├── finance/
│       ├── journal/
│       └── settings/
├── test/                          # unit + widget + migration tests
├── docs/
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

قاعده: هر feature دارای `data/`, `application/`, `domain/`, `presentation/` است؛ فقط ویجتهای مشترک در `core/widgets` قرار میگیرند.

## ۳. State و Codegen

- `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`.
- فایلهای `.g.dart` / `.freezed.dart` توسط `build_runner` ساخته میشوند و در ریپو کامیت میشوند تا CI نیازی به codegen جداگانه نداشته باشد (اما CI آن را بهعنوان مرحله تأیید اجرا میکند).
- مدلهای Drift با `@DriftTableName` و DataClassها توسط `drift_dev` تولید میشوند.
- Providers:
  - `databaseProvider` → `appDatabaseProvider`
  - `tasksRepositoryProvider`, `habitsRepositoryProvider`, …
  - `todaySummaryProvider` = ترکیب استریمهای tasks/habits/transactions/journal.
- نوشتنها همیشه در Repository و با تراکنش انجام میشوند (مثلاً محدودیت ۳ تمرکز).

## ۴. ناوبری

- `GoRouter` + `StatefulShellRoute.indexedStack`.
- مسیرها: `/today`, `/tasks`, `/habits`, `/finance`, `/journal`, `/settings`.
- Quick Add بهصورت `showModalBottomSheet` سراسری (با `rootNavigator: true`) از هر مسیر قابل باز شدن است.
- انیمیشن گذار: فنر نرم ۲۲۰ms؛ احترام به `MediaQuery.disableAnimations`.
- حفظ state تبها و scroll position هنگام جابهجایی الزامی است (DoD فاز ۱).

## ۵. جریان داده نمونه: تیک زدن عادت

```
User tap → HapticFeedback.lightImpact()
         → HabitsRepository.toggle(dateKey, habitId)   [transaction]
         → Drift watchHabitLogs() emits
         → habitStreakProvider recomputes (pure)
         → Today strip + Heatmap rebuild (< 1 frame)
```

هیچ اسپینری وجود ندارد؛ مقادیر خالی، «—» یا EmptyState معنیدار نشان داده میشوند.

## ۶. سرویسهای سیستمی

| سرویس | بسته | نکته پیادهسازی |
|---|---|---|
| Haptics | `HapticFeedback` بومی | فقط impact/selection؛ ویبره طولانی ممنوع |
| اعلان محلی | `flutter_local_notifications` | مجوز Android 13+؛ پیشفرض inexact |
| بیومتریک | `local_auth` | خاموش پیشفرض، فقط قفل اختیاری |
| بکاپ | `file_picker` + `share_plus` | SAF، JSON نسخهدار، اسنپشات قبل از import |
| قفل صفحه | `flutter_windowmanager` (اختیاری) | فقط اگر FlagSecure لازم شد |

## ۷. تاریخ، اعداد و فرمت

- `Jalali` از `shamsi_date`، تبدیل واحد در `JalaliHelper`.
- `dateKey` همیشه ISO میلادی (`YYYY-MM-DD`) در دیتابیس؛ نمایش `سهشنبه، ۴ آذر ۱۴۰۵`.
- اعداد فارسی با `NumberFormat` / جد welkeاینده `fa` + `FontFeature.tabularFigures()`.
- پول: `Int` تومان → `۱۲۵,۰۰۰ تومان`.

## ۸. خطاها، لاگ و حریم خصوصی

- خطاهای کاربرپسند از طریق `AsyncError` Riverpod + SnackBar/Inline message؛ stack traceها فقط در debug لاگ میشوند.
- هیچ Analytics، کراش reporting برونساز یا دسترسی اینترنتی در فازهای ۱–۵ وجود ندارد (Local-first=true).
- تمام دادهها در حافظه خصوصی اپ / SQLite ذخیره میشوند؛ خروجی بکاپ تنها با اقدام صریح کاربر share میشود.

## ۹. تست و کیفیت

| نوع | ابزار | موارد الزامی |
|---|---|---|
| Unit | `flutter_test` | Jalali conversion/leap، currency، streak، safe-to-spend، alternate repeat |
| Widget | `flutter_test` | Quick Add ۴ تب، BentoCard tap، RTL layout |
| Migration | تست migration با `drift_dev` | v1 → v2 بدون از دست رفتن داده |
| Static | `flutter analyze` | صفر warning و صفر issue |
| Golden (اختیاری) | `flutter_test` | تم تاریک/روشن صفحه امروز |

معیار خروج هر فاز: `analyze` + `test` سبز و ریپو بدون فایل مولد قدیمی ناسازگار.

## ۱۰. عملکرد

- Impeller پیشفرض نسخه 3.50.1؛ از غیرفعالسازی آن پرهیز شود.
- لیستها `ListView.builder` / `SliverList` با `const` ویجتها؛ Heatmap ۹۰ روز حداکثر ۹۰ سلول.
- انیمیشنها ۱۸۰–۲۲۰ms با منحنی springs و احترام به reduced motion.
- هدف: ≤ ۳ ثانیه برای ثبت، بدون spinner، و ≤ ۱ فریم تأخیر در تیک زدن.
