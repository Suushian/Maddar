import 'dart:math' as math;

import 'package:flutter/material.dart';

/// سیستم حرکت واحد مدار: تمامی ورودها، فشارها و تعویضها از اینجا میآیند.
///
/// تمام انیمیشنها با `MediaQuery.disableAnimations` خاموش میشوند تا تنظیم
/// «کاهش حرکت» کاربر بهطور واقعی رعایت شود.
abstract final class Motion {
  /// کوچکترین بازخوردها (آیکونها، چیپها و نقاط).
  static const Duration micro = Duration(milliseconds: 120);

  /// بازخوردهای معمولی (فشار دکمه، تعویض تب).
  static const Duration fast = Duration(milliseconds: 180);

  /// ورود المانها و تغییر مقادیر.
  static const Duration base = Duration(milliseconds: 260);

  /// حرکات تأکیدی مانند تکمیل شدن یک کار.
  static const Duration slow = Duration(milliseconds: 380);

  /// فاصلهیی که بین ورود عناصر متوالی رعایت میشود.
  static const Duration stagger = Duration(milliseconds: 28);

  /// نامهای قدیمی برای سازگاری با کدهای موجود.
  static const Duration step = stagger;
  static const Duration duration = base;
  static const Duration page = base;

  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// ورود نرم و پلهای: محو شدن + بالا آمدن خیلی کوتاه + کمی بزرگ شدن.
  ///
  /// [index] ترتیب ورود را مشخص میکند و [id] جلوی پخش دوبارهی ورود
  /// هنگام بازسازی widget را میگیرد.
  static Widget entrance(
    BuildContext context,
    Widget child,
    int index, {
    Object? id,
  }) {
    if (reduced(context)) {
      return child;
    }
    final int safeIndex = index < 0 ? 0 : (index > 12 ? 12 : index);
    final int delayMs = stagger.inMilliseconds * safeIndex;
    final int totalMs = delayMs + base.inMilliseconds;
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('motion-ent-${id ?? ''}-$safeIndex'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      builder: (BuildContext context, double value, Widget? child) {
        final double raw = ((value * totalMs - delayMs) /
                base.inMilliseconds)
            .clamp(0.0, 1.0);
        final double t = Curves.easeOutCubic.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - t)),
            child: Transform.scale(scale: 0.985 + 0.015 * t, child: child),
          ),
        );
      },
      child: child,
    );
  }

  /// بازخورد لمسی: هنگام نگه داشتن کوچک و هنگام رها کردن با Spring برمیگردد.
  static Widget press(
    BuildContext context,
    Widget child, {
    double minScale = 0.96,
  }) {
    if (reduced(context)) {
      return child;
    }
    return PressScale(minScale: minScale, child: child);
  }

  /// یک تپ ملایم تأکیدی برای موفقیتها (تیک، ذخیره، تغییر تم).
  static Widget pulse(
    BuildContext context,
    Widget child, {
    double scale = 1.06,
    Object? id,
  }) {
    if (reduced(context)) {
      return child;
    }
    return TweenAnimationBuilder<double>(
      key: ValueKey<String>('motion-pulse-${id ?? ''}'),
      tween: Tween<double>(begin: 0, end: 1),
      duration: base,
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) =>
          Transform.scale(
        scale: 1 + (scale - 1) * math.sin(math.pi * value),
        child: child,
      ),
      child: child,
    );
  }

  /// تعویض محتوا با محو + سر خوردن کوتاه (برای مراحل و تبها).
  static Widget swap(
    BuildContext context,
    Widget child,
    Object key, {
    Axis axis = Axis.vertical,
  }) {
    final Widget body = KeyedSubtree(key: ValueKey<Object>(key), child: child);
    if (reduced(context)) {
      return body;
    }
    return AnimatedSwitcher(
      duration: fast,
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final Offset begin = axis == Axis.vertical
            ? const Offset(0, 0.035)
            : const Offset(0.035, 0);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(
              Tween<Offset>(begin: begin, end: Offset.zero),
            ),
            child: child,
          ),
        );
      },
      child: body,
    );
  }

  /// تغییر عددها با محو و سر خوردن جزئی بهجای پرش ناگهانی.
  static Widget number(
    BuildContext context,
    num value,
    String Function(num value) format, {
    TextStyle? style,
    Object? id,
    TextAlign textAlign = TextAlign.start,
  }) {
    final Widget text = Text(
      format(value),
      style: style,
      textAlign: textAlign,
    );
    if (reduced(context)) {
      return text;
    }
    return AnimatedSwitcher(
      duration: fast,
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (Widget child, Animation<double> animation) =>
          FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(0, 0.14), end: Offset.zero),
          ),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey<String>('$id-${format(value)}'), child: text),
    );
  }
}

/// لایهای که فقط بازخورد فشردهشدن ایجاد میکند و در لمسها دخالت نمیکند.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.minScale = 0.96,
  });

  final Widget child;
  final double minScale;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _down = false;

  void _setDown(bool value) {
    if (_down != value && mounted) {
      setState(() => _down = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => _setDown(true),
      onPointerUp: (_) => _setDown(false),
      onPointerCancel: (_) => _setDown(false),
      child: AnimatedScale(
        scale: _down ? widget.minScale : 1,
        duration: _down ? Motion.micro : Motion.base,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
