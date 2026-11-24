import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// تم پیشفرض مدار، تاریک است. تغییر آن در تنظیمات بلافاصله اعمال میشود.
final themeModeProvider =
    StateProvider<ThemeMode>((ref) => ThemeMode.dark);
