/// فرمت مبلغ به تومان با اعداد فارسی و جداکننده سهرقمی.
abstract final class CurrencyFormatter {
  static const String _faDigits = '۰۱۲۳۴۵۶۷۸۹';
  static const String _asciiDigits = '0123456789';
  static const String currencyLabel = 'تومان';

  static String _toFa(String text) {
    final StringBuffer out = StringBuffer();
    for (final String char in text.split('')) {
      final int index = _asciiDigits.indexOf(char);
      out.write(index == -1 ? char : _faDigits[index]);
    }
    return out.toString();
  }

  static String _group(String digits) {
    final StringBuffer out = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        out.write(',');
      }
      out.write(digits[i]);
    }
    return out.toString();
  }

  static String digits(int value) => _toFa(value.toString());

  /// مثال: ۱۲۵,۰۰۰ تومان
  static String format(int toman) =>
      '${_toFa(_group(toman.toString()))} $currencyLabel';

  /// متن کوتاه برای کارتهای Bento: ۱۲۵ هزار / ۲ میلیون
  static String compact(int toman) {
    if (toman >= 1000000) {
      return '${digits(toman ~/ 1000000)} میلیون $currencyLabel';
    }
    if (toman >= 1000) {
      return '${digits(toman ~/ 1000)} هزار $currencyLabel';
    }
    return format(toman);
  }

  /// ورودی کیپد میتواند شامل ارقام فارسی، عربی یا جداکننده باشد.
  static int parse(String input) {
    final StringBuffer ascii = StringBuffer();
    for (final int unit in input.codeUnits) {
      if (unit >= 0x0660 && unit <= 0x0669) {
        ascii.write(unit - 0x0660);
      } else if (unit >= 0x06F0 && unit <= 0x06F9) {
        ascii.write(unit - 0x06F0);
      } else if (unit >= 48 && unit <= 57) {
        ascii.writeCharCode(unit);
      }
    }
    return int.tryParse(ascii.toString()) ?? 0;
  }
}
