# یادداشت پیادهمسازی فاز ۲

## تصمیم اجرایی

در محیط ساخت پروژه، Dart SDK و `build_runner` در دسترس نبودند، بنابراین کد تولیدشده Drift (`*.g.dart`) قابل ایجاد نبود. برای اینکه لایه داده **قابل اجرا و بدون فایل ناقص** بماند:

- کلاس `AppDatabase` مستقیماً از `GeneratedDatabase` Drift ارثبری میکند.
- جداول هفتگانه با SQL صریح در `MigrationStrategy.onCreate` ساخته میشوند.
- تمام نوشتنها از `customStatement` و تمام خواندنها از `customSelect`Drift انجام میشود.
- تراکنشها از `db.transaction(...)` و پراگمای `foreign_keys = ON` از `beforeOpen` استفاده میکنند.
- استریمها در لایه Repository با `StreamController` پخش میشوند (`ChangeEmitter.reactive`) تا رابط بدون refresh بهروز شود.

این پیادهسازی از همان موتور Drift/SQLite، همان اسکیمای [`04-DATA_MODEL.md`](04-DATA_MODEL.md) و همان قواعد تراکنشی (حداکثر ۳ تمرکز، toggle عادت) پیروی میکند. تنها تفاوت، نحوه تعریف جداول (SQL خام بهجای annotation/codegen) است.

## مسیر ارتقای آینده

وقتی `build_runner` در محیط توسعه موجود بود، میتوان جدولها را به `@DriftDatabase` + `@DriftAccessor` مهاجرت کرد و استریمهای Repository را با `watch()` جایگزین نمود. اسکیمای SQL و مدلها تغییری نمیکنند.

## فایلهای کلیدی

| فایل | نقش |
|---|---|
| `lib/core/database/app_database.dart` | اسکیمای ۷ جدول، ایندکسها، migration، clearAll |
| `lib/core/database/models.dart` | ۷ مدل تایپشده + fromRow/toJson/fromJson |
| `lib/core/database/repositories.dart` | CRUD تراکنشی + استریمهای پخش |
| `lib/core/database/backup_service.dart` | export/import JSON نسخهدار + اسنپشات |
| `lib/core/database/database_providers.dart` | Riverpod providers |
| `lib/core/utils/{repeat_rule_matcher,streak_calculator,budget_calculator}.dart` | منطق خالص قابل تست |
| `lib/features/today/application/today_summary.dart` | ترکیب استریمها برای خانه |
| `test/core/database/database_test.dart` | تست اسکیمای واقعی، محدودیت ۳ تمرکز، بکاپ |
| `test/core/utils/calculators_test.dart` | تست الگوی تکرار، Streak و بودجه |
