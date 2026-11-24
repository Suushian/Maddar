import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('مبلغ با جداکننده سهرقمی و اعداد فارسی نمایش داده میشود', () {
      expect(CurrencyFormatter.format(125000), '۱۲۵,۰۰۰ تومان');
      expect(CurrencyFormatter.format(1000), '۱,۰۰۰ تومان');
      expect(CurrencyFormatter.format(0), '۰ تومان');
    });

    test('اعداد صرفاً به فارسی تبدیل میشوند', () {
      expect(CurrencyFormatter.digits(1405), '۱۴۰۵');
    });

    test('ورودی فارسی و عربی به عدد باز میگردد', () {
      expect(CurrencyFormatter.parse('۱۲۵,۰۰۰'), 125000);
      expect(CurrencyFormatter.parse('۱۲۵٬۰۰۰'), 125000);
      expect(CurrencyFormatter.parse('125000'), 125000);
      expect(CurrencyFormatter.parse(''), 0);
    });

    test('فرمت کوتاه برای کارتهای Bento', () {
      expect(CurrencyFormatter.compact(125000), '۱۲۵ هزار تومان');
      expect(CurrencyFormatter.compact(2000000), '۲ میلیون تومان');
      expect(CurrencyFormatter.compact(500), '۵۰۰ تومان');
    });
  });
}
