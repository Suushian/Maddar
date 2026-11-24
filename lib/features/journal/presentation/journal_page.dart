import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/database/database_providers.dart';
import 'package:madaar/core/database/models.dart';
import 'package:madaar/core/database/repositories.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/jalali_helper.dart';
import 'package:madaar/core/widgets/async_repo_view.dart';
import 'package:madaar/core/widgets/bento_card.dart';
import 'package:madaar/core/widgets/module_header.dart';

class JournalPage extends ConsumerStatefulWidget {
  const JournalPage({super.key});

  @override
  ConsumerState<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends ConsumerState<JournalPage> {
  static const List<String> _tagOptions = <String>[
    'کار',
    'خانواده',
    'سلامت',
    'یادگیری',
    'آرامش',
  ];

  final TextEditingController _content = TextEditingController();
  int _mood = 4;
  int _energy = 3;
  final Set<String> _tags = <String>{};

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = AppColors.accent(context, MadaarAccent.journal);
    final AsyncValue<JournalRepository> repoAsync =
        ref.watch(journalRepositoryProvider);
    final String today = JalaliHelper.dateKey(DateTime.now());

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            ModuleHeader(
              title: 'دفتر شبانه',
              subtitle: 'سه خط، بدون فشار',
              accent: accent,
            ),
            Expanded(
              child: AsyncRepoView<JournalRepository>(
                value: repoAsync,
                builder: (JournalRepository repo) => StreamBuilder<List<JournalModel>>(
                  stream: repo.watchAll(),
                  builder: (
                    BuildContext context,
                    AsyncSnapshot<List<JournalModel>> snapshot,
                  ) {
                    final JournalModel? todayEntry =
                        (snapshot.data ?? const <JournalModel>[]).cast<JournalModel?>().firstWhere(
                              (JournalModel? entry) => entry?.dateKey == today,
                              orElse: () => null,
                            );
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      children: <Widget>[
                        BentoCard(
                          accent: accent,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                JalaliHelper.fullDate(DateTime.now()),
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'حال عمومی',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              _scoreSelector(
                                value: _mood,
                                icons: const <IconData>[
                                  Icons.sentiment_very_dissatisfied_rounded,
                                  Icons.sentiment_dissatisfied_rounded,
                                  Icons.sentiment_neutral_rounded,
                                  Icons.sentiment_satisfied_rounded,
                                  Icons.sentiment_very_satisfied_rounded,
                                ],
                                color: accent,
                                onChanged: (int value) =>
                                    setState(() => _mood = value),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'انرژی',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              _scoreSelector(
                                value: _energy,
                                icons: const <IconData>[
                                  Icons.battery_0_bar_rounded,
                                  Icons.battery_1_bar_rounded,
                                  Icons.battery_2_bar_rounded,
                                  Icons.battery_3_bar_rounded,
                                  Icons.battery_4_bar_rounded,
                                ],
                                color: AppColors.habits,
                                onChanged: (int value) =>
                                    setState(() => _energy = value),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 8,
                                children: <Widget>[
                                  for (final String tag in _tagOptions)
                                    FilterChip(
                                      label: Text(tag),
                                      selected: _tags.contains(tag),
                                      onSelected: (selected) => setState(() {
                                        if (selected) {
                                          _tags.add(tag);
                                        } else {
                                          _tags.remove(tag);
                                        }
                                      }),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: _content,
                                maxLines: 5,
                                decoration: InputDecoration(
                                  hintText: 'امروز چه گذشت؟',
                                  filled: true,
                                  fillColor: AppColors.bgSurface(context),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: FilledButton(
                                  onPressed: () async {
                                    await repo.upsert(
                                      dateKey: today,
                                      moodScore: _mood,
                                      energyScore: _energy,
                                      tagsJson: jsonEncode(_tags.toList()),
                                      content: _content.text.trim(),
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('ثبت شد'),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(todayEntry == null
                                      ? 'ذخیره یادداشت'
                                      : 'بهروزرسانی یادداشت'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _moodChart(context, snapshot.data ?? const <JournalModel>[]),
                        const SizedBox(height: 16),
                        if (snapshot.data != null &&
                            snapshot.data!.isNotEmpty)
                          BentoCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  ' گذشته',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                for (final JournalModel entry
                                    in snapshot.data!
                                        .where((item) => item.dateKey != today)
                                        .take(10))
                                  ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      entry.content.isEmpty
                                          ? 'یادداشت بدون متن'
                                          : entry.content,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      '${JalaliHelper.shortDate(
                                        JalaliHelper.fromDateKey(entry.dateKey),
                                      )} · خلق: ${JalaliHelper.faDigits(entry.moodScore)}/۵',
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _content.text = entry.content;
                                        _mood = entry.moodScore;
                                        _energy = entry.energyScore;
                                        _tags
                                          ..clear()
                                          ..addAll(
                                            (jsonDecode(entry.tagsJson)
                                                    as List<dynamic>)
                                                .cast<String>(),
                                          );
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodChart(BuildContext context, List<JournalModel> entries) {
    final String month = JalaliHelper.jalaliMonthKey(DateTime.now());
    final List<JournalModel> monthEntries = entries
        .where(
          (entry) =>
              JalaliHelper.jalaliMonthKey(
                JalaliHelper.fromDateKey(entry.dateKey),
              ) ==
              month,
        )
        ..sort((a, b) => a.dateKey.compareTo(b.dateKey));

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'نوسان روحیه در ماه شمسی جاری',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: monthEntries.isEmpty
                ? const Center(child: Text('با اولین ثبت، نمودار شکل میگیرد'))
                : LineChart(
                    LineChartData(
                      lineBarsData: <LineChartBarData>[
                        LineChartBarData(
                          spots: <FlSpot>[
                            for (int i = 0; i < monthEntries.length; i++)
                              FlSpot(i.toDouble(), monthEntries[i].moodScore.toDouble()),
                          ],
                          isCurved: true,
                          color: AppColors.accent(context, MadaarAccent.journal),
                          barWidth: 2.5,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      minY: 1,
                      maxY: 5,
                      titlesData: const FlTitlesData(show: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _scoreSelector({
    required int value,
    required List<IconData> icons,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Wrap(
      spacing: 6,
      children: <Widget>[
        for (int i = 1; i <= icons.length; i++)
          IconButton(
            tooltip: '${JalaliHelper.faDigits(i)} از ۵',
            onPressed: () => onChanged(i),
            icon: Icon(
              icons[i - 1],
              color: value >= i ? color : AppColors.textMuted(context),
            ),
          ),
      ],
    );
  }
}
