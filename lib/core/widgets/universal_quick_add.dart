import 'dart:async';

import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/haptics.dart';

/// شیت چهارتبه ثبت سریع که از تمام صفحات در دسترس است.
/// در فاز ۱ رابط و جریان آن آماده است و اتصال به Repositoryها در فاز ۳ انجام میشود.
class UniversalQuickAdd extends StatefulWidget {
  const UniversalQuickAdd({super.key, this.initialTab = 0});

  final int initialTab;

  static Future<void> show(BuildContext context, {int initialTab = 0}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) =>
          UniversalQuickAdd(initialTab: initialTab),
    );
  }

  @override
  State<UniversalQuickAdd> createState() => _UniversalQuickAddState();
}

class _UniversalQuickAddState extends State<UniversalQuickAdd>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab < 0
          ? 0
          : (widget.initialTab > 3 ? 3 : widget.initialTab),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.72,
        decoration: BoxDecoration(
          color: AppColors.bgElevated(context).withValues(alpha: 0.97),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: AppColors.borderSubtle(context)),
        ),
        child: Column(
          children: <Widget>[
            Text(
              'ثبت سریع',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            TabBar(
              controller: _controller,
              labelColor: AppColors.brand(context),
              unselectedLabelColor: AppColors.textMuted(context),
              indicatorColor: AppColors.brand(context),
              dividerColor: AppColors.borderSubtle(context),
              labelStyle: const TextStyle(
                fontFamily: 'Vazirmatn',
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              tabs: const <Widget>[
                Tab(text: 'کار'),
                Tab(text: 'تراکنش'),
                Tab(text: 'حس امروز'),
                Tab(text: 'عادت'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _controller,
                children: <Widget>[
                  _QuickForm(
                    title: 'کار جدید',
                    hint: 'عنوان کار را بنویسید…',
                    chips: const <String>['کار و رشد', 'سلامتی', 'شخصی', 'یادگیری'],
                    actionLabel: 'ذخیره کار',
                    onSave: () => _close(context),
                  ),
                  _QuickForm(
                    title: 'تراکنش مالی',
                    hint: 'مبلغ به تومان…',
                    chips: const <String>['خوراک', 'رفت و آمد', 'خرید', 'قبض'],
                    actionLabel: 'ذخیره تراکنش',
                    onSave: () => _close(context),
                  ),
                  _QuickForm(
                    title: 'حالوهوای امروز',
                    hint: 'بهترین لحظه کوچک امروز چی بود؟',
                    chips: const <String>['خواب خوب', 'ورزش', 'خانواده', 'استرس مالی'],
                    actionLabel: 'ذخیره حس',
                    onSave: () => _close(context),
                    maxLines: 3,
                  ),
                  _QuickForm(
                    title: 'عادت جدید',
                    hint: 'نام عادت…',
                    chips: const <String>['هر روز', 'روزهای هفته', 'زوج/فرد'],
                    actionLabel: 'ذخیره عادت',
                    onSave: () => _close(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _close(BuildContext context) {
    unawaited(Haptics.success());
    Navigator.of(context).pop();
  }
}

class _QuickForm extends StatelessWidget {
  const _QuickForm({
    required this.title,
    required this.hint,
    required this.chips,
    required this.actionLabel,
    required this.onSave,
    this.maxLines = 1,
  });

  final String title;
  final String hint;
  final List<String> chips;
  final String actionLabel;
  final VoidCallback onSave;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(
            maxLines: maxLines,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppColors.bgSurface(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.borderSubtle(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: AppColors.borderSubtle(context)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final String chip in chips)
                Chip(
                  label: Text(chip),
                  visualDensity: VisualDensity.compact,
                  side: BorderSide(color: AppColors.borderSubtle(context)),
                  backgroundColor: AppColors.bgSurface(context),
                ),
            ],
          ),
          const Spacer(),
          FilledButton(
            onPressed: onSave,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
