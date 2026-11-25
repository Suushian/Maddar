import 'package:flutter/material.dart';
import 'package:madaar/core/theme/app_colors.dart';
import 'package:madaar/core/utils/currency_formatter.dart';
import 'package:madaar/core/utils/jalali_helper.dart';

/// فرم سریع تراکنش و قسط ثابت (روی یک قلم).
class FinanceEntrySheet extends StatefulWidget {
  const FinanceEntrySheet({super.key, required this.onSave});

  final Future<void> Function({
    required String note,
    required int amount,
    required String categoryId,
    required DateTime transactedAt,
    required String type,
  }) onSave;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required String note,
      required int amount,
      required String categoryId,
      required DateTime transactedAt,
      required String type,
    }) onSave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FinanceEntrySheet(onSave: onSave),
    );
  }

  @override
  State<FinanceEntrySheet> createState() => _FinanceEntrySheetState();
}

class _FinanceEntrySheetState extends State<FinanceEntrySheet> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  String _type = 'expense';
  String _category = 'other';
  DateTime _date = DateTime.now();
  bool _keypadMode = true;

  static const List<String> _categories = <String>[
    'other',
    'food',
    'transport',
    'home',
    'health',
    'shopping',
    'entertainment',
    'income',
    'savings',
  ];

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  void _pressKeypad(String key) {
    final int current = CurrencyFormatter.parse(_amount.text);
    if (key == 'C') {
      _amount.clear();
      return;
    }
    if (key == '⌫') {
      final String digits = current.toString();
      _amount.text = digits.length <= 1
          ? ''
          : CurrencyFormatter.format(int.parse(digits.substring(0, digits.length - 1)));
      return;
    }
    if (key.startsWith('+')) {
      _amount.text =
          CurrencyFormatter.format(current + int.parse(key.substring(1)));
      return;
    }
    final int next = int.parse('$current$key');
    _amount.text = CurrencyFormatter.format(next);
  }

  @override
  Widget build(BuildContext context) {
    final double keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgElevated(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(color: AppColors.borderSubtle(context)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('تراکنش جدید', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'عنوان (مثلاً: ناهار)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              readOnly: _keypadMode,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'مبلغ به تومان',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('کیپد مخصوص مبلغ'),
              value: _keypadMode,
              onChanged: (bool value) => setState(() => _keypadMode = value),
            ),
            if (_keypadMode)
              _AmountKeypad(onPress: _pressKeypad),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'نوع'),
                    items: const <DropdownMenuItem<String>>[
                      DropdownMenuItem<String>(
                        value: 'expense',
                        child: Text('هزینه'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'income',
                        child: Text('درآمد'),
                      ),
                    ],
                    onChanged: (String? value) =>
                        setState(() => _type = value ?? 'expense'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'دسته'),
                    items: _categories
                        .map(
                          (String item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          ),
                        )
                        .toList(),
                    onChanged: (String? value) =>
                        setState(() => _category = value ?? 'other'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('تاریخ: ${JalaliHelper.fullDate(_date)}'),
              trailing: const Icon(Icons.calendar_today_rounded),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(1400),
                  lastDate: DateTime(1450),
                );
                if (picked != null) {
                  setState(() => _date = picked);
                }
              },
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                final int amount = CurrencyFormatter.parse(_amount.text);
                final String title = _title.text.trim();
                if (amount <= 0 || title.isEmpty) {
                  return;
                }
                await widget.onSave(
                  note: title,
                  amount: amount,
                  categoryId: _category,
                  transactedAt: _date,
                  type: _type,
                );
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text('ذخیره'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AmountKeypad extends StatelessWidget {
  const _AmountKeypad({required this.onPress});

  final ValueChanged<String> onPress;

  static const List<String> _keys = <String>[
    '1', '2', '3', '+50000',
    '4', '5', '6', '+100000',
    '7', '8', '9', '⌫',
    '0', '000', '00', 'C',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: <Widget>[
        for (final String key in _keys)
          SizedBox(
            width: 64,
            child: OutlinedButton(
              onPressed: () => onPress(key),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                key == '⌫' ? '⟵' : key == 'C' ? 'C' : key.startsWith('+')
                    ? key == '+50000' ? '+۵۰ هزار' : '+۱۰۰ هزار'
                    : JalaliHelper.faDigits(key),
              ),
            ),
          ),
      ],
    );
  }
}
