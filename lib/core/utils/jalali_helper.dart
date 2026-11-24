import 'package:shamsi_date/shamsi_date.dart';

/// تنها نقطه تبدیل تاریخ: تاریخها در دیتابیس میلادی و در رابط شمسی نمایش داده میشوند.
abstract final class JalaliHelper {
  static const String _faDigits = '۰۱۲۳۴۵۶۷۸۹';
  static const String _asciiDigits = '0123456789';

  /// تبدیل هر عدد به ارقام فارسی.
  static String faDigits(Object value) {
    final String text = value.toString();
    final StringBuffer out = StringBuffer();
    for (final String char in text.split('')) {
      final int index = _asciiDigits.indexOf(char);
      out.write(index == -1 ? char : _faDigits[index]);
    }
    return out.toString();
  }

  /// کلید پایدار روز در دیتابیس: ISO میلادی.
  static String dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  static DateTime fromDateKey(String key) {
    final List<String> parts = key.split('-');
    if (parts.length != 3) {
      throw FormatException('dateKey نامعتبر است: $key');
    }
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static Jalali toJalali(DateTime date) => Jalali.fromDateTime(date);

  /// مثال: سهشنبه، ۴ آذر ۱۴۰۵
  static String fullDate(DateTime date) {
    final Jalali jalali = toJalali(date);
    return '${jalali.formatter.wN}، '
        '${faDigits(jalali.formatter.d)} '
        '${jalali.formatter.mN} '
        '${faDigits(jalali.formatter.yyyy)}';
  }

  /// مثال: ۴ آذر
  static String shortDate(DateTime date) {
    final Jalali jalali = toJalali(date);
    return '${faDigits(jalali.formatter.d)} ${jalali.formatter.mN}';
  }

  /// کلید ماه شمسی برای گروهبندی بودجه و قبوض: YYYY-MM (اعداد لاتین).
  static String jalaliMonthKey(DateTime date) {
    final Jalali jalali = toJalali(date);
    return '${jalali.year.toString().padLeft(4, '0')}-'
        '${jalali.month.toString().padLeft(2, '0')}';
  }

  static int jalaliMonthLength(int year, int month) =>
      Jalali(year, month, 1).monthLength;

  static bool isLeapYear(int year) => Jalali(year, 12, 1).isLeapYear();

  static String greeting(DateTime date) {
    final int hour = date.hour;
    if (hour < 12) {
      return 'صبح بخیر';
    }
    if (hour < 18) {
      return 'عصر آرام';
    }
    return 'شب بخیر';
  }
}
