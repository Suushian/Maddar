# 🗄 مدل داده (Drift / SQLite)

> تمام تاریخها بهصورت متن ISO‑8601 (UTC) ذخیره میشوند، مگر `date_key` (روز میلادی `YYYY-MM-DD`) و `last_paid_jalali_month` (ماه شمسی `YYYY-MM`). تمام مبالغ `Int` به تومان است.

## ۰. قواعد کلی

- `foreign_keys = ON` در `MigrationStrategy.beforeOpen`.
-ทุก جدول دارای `id INTEGER PRIMARY KEY AUTOINCREMENT` مگر `app_settings`.
- تمام جدولهای روزانه دارای `created_at TEXT NOT NULL`اند.
- اعمال محدودیت «حداکثر ۳ تمرکز» و تکرار عادت در لایه Repository با تراکنش انجام میشود (ADR‑004/005).

---

## ۱. `tasks`

| فیلد | نوع | توضیح |
|---|---|---|
| `id` | Int PK auto | — |
| `title` | Text NOT NULL | حداکثر ۱۲۰ کاراکتر |
| `note` | Text NULL | — |
| `pillar` | Text NOT NULL | `work`, `health`, `personal`, `learning` |
| `due_date` | Text NULL | ISO میلادی؛ NULL → Inbox |
| `focus_date` | Text NULL | ISO میلادی؛ روزی که این کار «تمرکز» است (ADR‑004) |
| `is_top_focus` | Bool DEFAULT 0 | CHECK: `0 OR focus_date IS NOT NULL` |
| `priority` | Int DEFAULT 0 | `0=normal`, `1=high` |
| `is_completed` | Bool DEFAULT 0 | — |
| `completed_at` | Text NULL | ISO8601 UTC |
| `created_at` | Text NOT NULL | ISO8601 UTC |

**ایندکسها:** `(due_date)`, `(focus_date, is_top_focus)`, `(is_completed, due_date)`.
**قاعده:** حداکثر ۳ ردیف با `is_top_focus=1` بهازای هر `focus_date`؛ چهارمین تلاش با پیام «حداکثر ۳ تمرکز در روز مجاز است» رد میشود.

## ۲. `habits`

| فیلد | نوع | توضیح |
|---|---|---|
| `id` | Int PK auto | — |
| `title`, `icon_code`, `color_hex` | Text | نام، نام آیکون، `#RRGGBB` |
| `repeat_type` | Text | `daily`, `weekly`, `alternate` (ADR‑005) |
| `weekday_mask` | Int NULL | ۱=شنبه … ۶۴=جمعه، ۱۲۷=همه؛ فقط برای `weekly` |
| `repeat_anchor_date` | Text NULL | تاریخ آغاز الگوی alternate |
| `sort_order` | Int DEFAULT 0 | — |
| `is_archived` | Bool DEFAULT 0 | بایگانی بهجای حذف |
| `created_at` | Text NOT NULL | — |

**قاعده alternate:** پاریته براساس **شماره مطلق روز شمسی** ( تعداد روزها از مبدأ جلالی) محاسبه میشود؛ `repeat_anchor_date` مشخص میکند کدام پاریته («زوج» یا «فرد») جزء روزهای فعال است. در مرز ماهها اتفاق نمیافتد.

## ۳. `habit_logs`

| فیلد | نوع | توضیح |
|---|---|---|
| `id` | Int PK auto | — |
| `habit_id` | Int FK → `habits.id` ON DELETE CASCADE | — |
| `date_key` | Text | ISO میلادی |
| `completed_at` | Text NOT NULL | ISO8601 UTC |

**UNIQUE:** `(habit_id, date_key)` — اصلاح روزهای گذشته با upsert انجام میشود.

## ۴. `transactions`

| فیلد | نوع | توضیح |
|---|---|---|
| `id` | Int PK auto | — |
| `amount` | Int > 0 | تومان |
| `type` | Text | `expense`, `income` |
| `category_id` | Text | `food`, `transport`, `shopping`, `bills`, `fun`, `health`, `income`, `savings` + سفارشی |
| `note` | Text NULL | — |
| `transacted_at` | Text NOT NULL | ISO8601 UTC |
| `created_at` | Text NOT NULL | — |

**ایندکسها:** `(transacted_at)`, `(category_id)`, `(type, transacted_at)`.

## ۵. `recurring_bills`

| فیلد | نوع | توضیح |
|---|---|---|
| `id` | Int PK auto | — |
| `title` | Text | — |
| `amount` | Int > 0 | تومان |
| `due_day` | Int 1..31 | روز شمسی (ADR‑006) |
| `last_paid_jalali_month` | Text NULL | `YYYY-MM` شمسی |
| `created_at` | Text NOT NULL | — |

**روز مؤثر:** `min(due_day, jalaliMonthLength(jalaliYear, jalaliMonth))`؛ اسفند ۲۹/۳۰ بر اساس الگوریتم کبیسه.

## ۶. `journal_entries`

| فیلد | نوع | توضیح |
|---|---|---|
| `id` | Int PK auto | — |
| `date_key` | Text UNIQUE | ISO میلادی؛ یک ثبت در هر شبانهروز |
| `mood_score` | Int 1..5 | — |
| `energy_score` | Int 1..5 | — |
| `tags_json` | Text | آرایه JSON از تگها (خواب خوب، ورزش، …) |
| `content` | Text | میکروژورنال ۳ خطی |
| `created_at`, `updated_at` | Text | ISO8601 UTC |

## ۷. `app_settings`

| فیلد | نوع | پیشفرض |
|---|---|---|
| `id` | Int PK CHECK(id=1) | تک ردیف |
| `user_name` | Text NULL | — |
| `theme_mode` | Text | `dark` |
| `monthly_budget` | Int NULL | — (در onboarding پر میشود) |
| `biometric_lock_enabled` | Bool | `false` |
| `daily_reminder_time` | Text NULL | `HH:mm` |
| `onboarding_completed` | Bool | `false` |
| `updated_at` | Text | ISO8601 |

---

## محاسبات مشتقشده (پیادهسازی pure، تستپذیر)

### Streak عادت
- **Eligible day:** روزی از `created_at` به بعد که طبق `repeat_type` عادت در آن روز انتظار میرود.
- **Current streak:** تعداد روزهای eligible متوالی که منتهی به امروز یا دیروز شود (دیروز مجاز است تا تیک دیرهنگام امروز قطع نشود).
- **Best streak:** حداکثر دنباله در تمام eligible days.
- **Monthly success rate:** `completed eligible days / all eligible days` در ماه شمسی جاری (۰ اگر صفر).

### Safe-to-spend
```
spent   = sum(expense transactions in current Jalali month)
fixed   = sum(unpaid recurring bills for current Jalali month)
safe    = max(0, monthlyBudget - spent - fixed)
perDay  = safe / remainingJalaliDays   (گرد به ۱۰۰۰ تومان)
```
متن: «امروز میتونی تا X خرج کنی تا آخر ماه تو مدار بمونی»؛ X = `perDay`، و `safe` در نوار پیشرفت نمایش داده میشود.

### درصد پیشرفت امروز
`(completed tasks focused today + checked habits today) / (all focused tasks today + all eligible habits today)` — اگر مخرج صفر باشد، ۰٪.

---

## بکاپ / بازیابی (ADR‑011)

```json
{
  "format": "madaar-backup",
  "schema_version": 1,
  "exported_at": "2026-11-24T12:00:00Z",
  "data": {
    "tasks": [], "habits": [], "habit_logs": [],
    "transactions": [], "recurring_bills": [],
    "journal_entries": [], "app_settings": []
  }
}
```

- Export: تمام جدولها به JSON، تاریخها به رشته، بولها به true/false.
- Import: اعتبارسنجی `format`، `schema_version`، تک Unique و FKها → **اسنپشات قبل از import** → درج در یک تراکنش → در صورت خطا بازگشت به snapshot.
- فایل خروجی توسط `share_plus` به کاربر داده میشود؛ هیچ آپلود خودسرانه وجود ندارد.

## migration

- `schemaVersion` در Drift با هر تغییر ساختار افزایش مییابد.
- `MigrationStrategy.migrations` شامل مسیرهای صریح (مثلاً `1 → 2`) است.
- تست migration: ساختن دیتابیس v1 با نمونه داده → اجرای migration → برابر کردن محتوا و اسکیمای v2.
- برای جداول بدون UNIQUE از `ALTER TABLE` با احتیاط استفاده میشود؛ در صورت نیاز، جدول جدید + کپی + rename در تراکنش.
