# 🎨 سیستم طراحی مدار

> تمام مقادیر این فایل مستقیماً توسط ویجتها خوانده میشوند؛ عدد جادویی در کد ممنوع است. تمام مقادیر از `ThemeData` و `AppColors` میآیند.

## ۱. فلسفه بصری

- **Tactile Luxury:** الهام از Things 3، Linear و Opal — سکوت بصری، فاصلهگذاری نفسگیر، واکنش لمسی ظریف.
- **Bento Grid:** کارتها در شبکهای با شعاع ۲۴px و فاصله ۱۲–۱۶px؛ اهمیت با اندازه کارت نه رنگ جارزننده منتقل میشود.
- **Soft Glassmorphism:** داک و شیتها از `BackdropFilter(blur: 20)` و حاشیه نورانی ۷% استفاده میکنند؛ روی تم روشن blur همراه سایه نرم است.

## ۲. توکنهای رنگی

### تم تاریک (Obsidian Dark — پیشفرض)

| توکن | مقدار | کاربرد |
|---|---|---|
| `bgPrimary` | `#090B0E` | پسزمینه AMOLED |
| `bgSurface` | `#12151B` | کارت Bento |
| `bgElevated` | `#1A1F28` | مودال، Bottom Sheet |
| `borderSubtle` | `#FFFFFF` @ 7% | خط دور کارتها |
| `textPrimary` | `#F3F5F8` | عنوانها |
| `textSecondary` | `#949EAE` | متن پشتیبان |
| `textMuted` | `#5B6472` | توضیحات ضعیف |

### تم روشن (Warm Paper Light)

| توکن | مقدار | کاربرد |
|---|---|---|
| `bgPrimary` | `#F6F5F1` | سفید کاغذی گرم |
| `bgSurface` | `#FFFFFF` | کارت |
| `bgElevated` | `#FFFFFF` + shadow(`blur 24`, `offset 0,8`, `rgba(15,23,42,0.06)`) | شیتها |
| `borderSubtle` | `#0F172A` @ 6% | خط دور |
| `textPrimary` | `#11151C` | عنوانها |
| `textSecondary` | `#525C6B` | متن پشتیبان |
| `textMuted` | `#8E98A8` | توضیحات |

### رنگهای معناگرا

| توکن | تاریک | روشن | معنا |
|---|---|---|---|
| `brandPrimary` | `#818CF8` | `#6366F1` | نیلی کهکشانی / برند |
| `tasksAccent` | `#38BDF8` | `#38BDF8` | کار و تمرکز |
| `habitsAccent` | `#10B981` | `#059669` | عادت و سرزندگی |
| `financeIncome` | `#22C55E` | `#16A34A` | درآمد |
| `financeExpense` | `#FB7185` | `#F59E0B` | هزینه (ملایم، نه قرمز تند) |
| `journalAccent` | `#C084FC` | `#A855F7` | ذهن و ژورنال |

حالت تم: `themeMode ∈ {dark, light, system}`، ذخیره در `app_settings`، پیشفرض `dark`.

## ۳. تایپوگرافی

- فونت: **Vazirmatn v33.003** — وزنهای 300، 400، 500، 700، 800 بهصورت static TTF باندلشده در `assets/fonts/vazirmatn/`.
- فایل مجوز `OFL.txt` در همان پوشه قرار میگیرد.
- بدون `google_fonts`، بدون درخواست شبکه، بدون fallback به فونت پیشفرض اندروید.
- مقیاس متن (sp): Display 28/800، Headline 22/700، Title 18/700، Body 15/400، Caption 12/500.
- تمام اعداد با `FontFeature.tabularFigures()` و اعداد فارسی نمایش داده میشوند.

## ۴. هندسه

| المان | شعاع (dp) | حاشیه/فاصله |
|---|---|---|
| کارت Bento | 24 | فاصله ۱۲–۱۶dp بین کارتها |
| دکمه / فیلد ورودی | 16 | padding 14–16 |
| چیپ / تگ | 12 | 8 افقی |
| Floating Glass Dock | 32 | ۱۶dp از پایین صفحه |
| آیکون دایرهای عادت | دایره کامل | hit target ≥ 48 |
| Heatmap سلول | 6 | gap 4 |

## ۵. حرکت (Motion)

| رویداد | انیمیشن |
|---|---|
| تیک کار/عادت | `scale 0.92 → 1` + پر شدن دایره + خط خوردن ملایم + `HapticFeedback.lightImpact()` |
| باز شدن Quick Add | Spring bottom sheet، 220ms، پسزمینه مات 40% |
| ورود کارتهای خانه | Staggered 40ms با `flutter_animate` |
| جابهجایی تب | 220ms، curve `easeOutCubic` |
| خطا/ردیت | لرزش 2dp، بدون رنگ قرمز تند |

قواعد: احترام به `MediaQuery.disableAnimations`، بدون انیمیشن بالای 300ms، بدون spinner در عملیات محلی.

## ۶. کامپوننتهای مشترک

| ویجت | مسئولیت |
|---|---|
| `BentoCard` | سطح، حاشیه نورانی، Ripple ظریف |
| `FloatingGlassDock` | ۵ تب + دکمه `+` برجسته 12dp، blur 20، hit target 48dp |
| `UniversalQuickAdd` | شیت چهارتبه: کار / تراکنش / حس امروز / عادت جدید |
| `NumericKeypad` | کیپد مالی اختیاری، جداکننده سهرقمی فارسی، دکمههای +۵۰ و +۱۰۰ هزار |
| `MoodIcon` | ۵ آیکون مینیمال خطی (نه ایموجی زرد کارتونی) |
| `ProgressRing` | درصد پیشرفت امروز، رنگ برند |
| `EmptyStateView` | پیام انگیزهای کوتاه + CTA؛ جای اسپینر را میگیرد |
| `HabitHeatmap` | ۳۰/۹۰ سلول گرد 6px، طیف رنگ عادت |

## ۷. RTL و چندزبانگی

- `Directionality(textDirection: TextDirection.rtl)` در ریشه، `ThemeData` لوکال `fa_IR`.
- آیکونهای جهتدار (فلش، swipe hint) در RTL آینه میشوند.
- تاریخها و اعداد فارسیاند؛ ترتیب راستبهچپ در لیستها و نمودارها رعایت میشود.
- حداقل اندازه لمس 48×48dp؛ تضاد رنگ حداقل WCAG AA؛ متنها قابل scale تا 200% بدون برش.

## ۸. نکات پیادهسازی

- رنگها بهصورت `Color(0xFF...)` در `AppColors` تعریف و با `withValues(alpha: .07)` شفافیت اعمال میشود؛ از `withOpacity` منسوخشده پرهیز شود.
- سایه تم روشن با `BoxShadow` و `blurRadius: 24` مطابق جدول بالا.
- فونت در `pubspec.yaml` باندل و در `ThemeData.textTheme` اعمال میشود.
- هیچ رنگ مستقیم در ویجت featureها ننویسید؛ همیشه `Theme.of(context).colorScheme` یا `AppColors` extension.
