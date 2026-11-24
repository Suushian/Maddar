import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/widgets/empty_state_view.dart';

/// بدون اسپینر: در زمان بارگذاری صبر میکند و در خطا پیام دوستانه نشان میدهد.
class AsyncRepoView<T> extends StatelessWidget {
  const AsyncRepoView({
    super.key,
    required this.value,
    required this.builder,
    this.errorTitle = ' دسترسی به داده ممکن نشد',
  });

  final AsyncValue<T> value;
  final Widget Function(T data) builder;
  final String errorTitle;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const SizedBox.shrink(),
      error: (Object error, StackTrace stack) => EmptyStateView(
        icon: Icons.error_outline_rounded,
        title: errorTitle.trimLeft(),
        message: 'دادهها روی دستگاه باقی ماندهاند. دوباره تلاش کنید.',
      ),
    );
  }
}
