import 'package:flutter_test/flutter_test.dart';
import 'package:madaar/core/utils/jalali_helper.dart';

void main() {
  group('JalaliHelper', () {
    test('dateKey به فرمت ایزو میلادی ذخیره میشود', () {
      expect(
        JalaliHelper.dateKey(DateTime(2026, 11, 24)),
        '2026-11-24',
      );
    });

    test('fromDateKey و dateKey معکوس یکدیگراند', () {
      const String key = '2026-11-24';
      expect(JalaliHelper.dateKey(JalaliHelper.fromDateKey(key)), key);
    });

    test('fromDateKey ورودی نامعتبر را رد میکند', () {
      expect(
        () => JalaliHelper.fromDateKey('not-a-date'),
        throwsFormatException,
      );
    });

    test('تاریخ کامل شامل نام ماه شمسی و اعداد فارسی است', () {
      final DateTime date = DateTime(2026, 11, 24);
      final String text = JalaliHelper.fullDate(date);
      final String month = JalaliHelper.toJalali(date).formatter.mN;
      expect(text, contains(month));
      expect(text, contains(RegExp(r'[۰-۹]')));
      expect(text, contains('،'));
    });

    test('طول ماههای شمسی مطابق تقویم جلالی است', () {
      expect(JalaliHelper.jalaliMonthLength(1405, 1), 31);
      expect(JalaliHelper.jalaliMonthLength(1405, 7), 30);
      expect(JalaliHelper.jalaliMonthLength(1405, 12), isIn(<int>[29, 30]));
    });

    test('کلید ماه شمسی چهار رقم سال و دو رقم ماه دارد', () {
      expect(JalaliHelper.jalaliMonthKey(DateTime(2026, 11, 24)), matches(r'^\d{4}-\d{2}$'));
    });

    test('خوشآمدگویی متناسب با ساعت است', () {
      expect(JalaliHelper.greeting(DateTime(2026, 11, 24, 9)), 'صبح بخیر');
      expect(JalaliHelper.greeting(DateTime(2026, 11, 24, 15)), 'عصر آرام');
      expect(JalaliHelper.greeting(DateTime(2026, 11, 24, 22)), 'شب بخیر');
    });
  });
}
