import 'package:drift/drift.dart';

/// ردیفهای خامDrift به مدلهای تایپشده لایه دامنه تبدیل میشوند.
abstract final class ModelParsers {
  static bool boolAt(QueryRow row, String key) => row.readInt(key) == 1;

  static int? nullableInt(QueryRow row, String key) => row.readNullable<int>(key);

  static int intAt(QueryRow row, String key, [int fallback = 0]) =>
      row.readNullable<int>(key) ?? fallback;
}

class TaskModel {
  const TaskModel({
    required this.id,
    required this.title,
    this.note,
    required this.pillar,
    this.dueDate,
    this.focusDate,
    required this.isTopFocus,
    required this.priority,
    required this.isCompleted,
    this.completedAt,
    required this.createdAt,
  });

  static const Set<String> pillars = <String>{
    'work',
    'health',
    'personal',
    'learning',
  };

  final int id;
  final String title;
  final String? note;
  final String pillar;
  final String? dueDate;
  final String? focusDate;
  final bool isTopFocus;
  final int priority;
  final bool isCompleted;
  final String? completedAt;
  final String createdAt;

  TaskModel copyWith({
    String? title,
    String? note,
    String? pillar,
    String? dueDate,
    String? focusDate,
    bool? isTopFocus,
    int? priority,
    bool? isCompleted,
    String? completedAt,
  }) =>
      TaskModel(
        id: id,
        title: title ?? this.title,
        note: note ?? this.note,
        pillar: pillar ?? this.pillar,
        dueDate: dueDate ?? this.dueDate,
        focusDate: focusDate ?? this.focusDate,
        isTopFocus: isTopFocus ?? this.isTopFocus,
        priority: priority ?? this.priority,
        isCompleted: isCompleted ?? this.isCompleted,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt,
      );

  factory TaskModel.fromRow(QueryRow row) => TaskModel(
        id: row.readInt('id'),
        title: row.readString('title'),
        note: row.readNullable<String>('note'),
        pillar: row.readString('pillar'),
        dueDate: row.readNullable<String>('due_date'),
        focusDate: row.readNullable<String>('focus_date'),
        isTopFocus: ModelParsers.boolAt(row, 'is_top_focus'),
        priority: row.readInt('priority'),
        isCompleted: ModelParsers.boolAt(row, 'is_completed'),
        completedAt: row.readNullable<String>('completed_at'),
        createdAt: row.readString('created_at'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'note': note,
        'pillar': pillar,
        'due_date': dueDate,
        'focus_date': focusDate,
        'is_top_focus': isTopFocus ? 1 : 0,
        'priority': priority,
        'is_completed': isCompleted ? 1 : 0,
        'completed_at': completedAt,
        'created_at': createdAt,
      };

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        note: json['note'] as String?,
        pillar: json['pillar'] as String,
        dueDate: json['due_date'] as String?,
        focusDate: json['focus_date'] as String?,
        isTopFocus: json['is_top_focus'] == 1,
        priority: (json['priority'] as num?)?.toInt() ?? 0,
        isCompleted: json['is_completed'] == 1,
        completedAt: json['completed_at'] as String?,
        createdAt: json['created_at'] as String,
      );
}

class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.iconCode,
    required this.colorHex,
    required this.repeatType,
    this.weekdayMask,
    this.repeatAnchorDate,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
  });

  static const Set<String> repeatTypes = <String>{
    'daily',
    'weekly',
    'alternate',
  };

  final int id;
  final String title;
  final String iconCode;
  final String colorHex;
  final String repeatType;
  final int? weekdayMask;
  final String? repeatAnchorDate;
  final int sortOrder;
  final bool isArchived;
  final String createdAt;

  factory HabitModel.fromRow(QueryRow row) => HabitModel(
        id: row.readInt('id'),
        title: row.readString('title'),
        iconCode: row.readString('icon_code'),
        colorHex: row.readString('color_hex'),
        repeatType: row.readString('repeat_type'),
        weekdayMask: row.readNullable<int>('weekday_mask'),
        repeatAnchorDate: row.readNullable<String>('repeat_anchor_date'),
        sortOrder: row.readInt('sort_order'),
        isArchived: ModelParsers.boolAt(row, 'is_archived'),
        createdAt: row.readString('created_at'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'icon_code': iconCode,
        'color_hex': colorHex,
        'repeat_type': repeatType,
        'weekday_mask': weekdayMask,
        'repeat_anchor_date': repeatAnchorDate,
        'sort_order': sortOrder,
        'is_archived': isArchived ? 1 : 0,
        'created_at': createdAt,
      };

  factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        iconCode: json['icon_code'] as String,
        colorHex: json['color_hex'] as String,
        repeatType: json['repeat_type'] as String,
        weekdayMask: (json['weekday_mask'] as num?)?.toInt(),
        repeatAnchorDate: json['repeat_anchor_date'] as String?,
        sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
        isArchived: json['is_archived'] == 1,
        createdAt: json['created_at'] as String,
      );
}

class HabitLogModel {
  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.dateKey,
    required this.completedAt,
  });

  final int id;
  final int habitId;
  final String dateKey;
  final String completedAt;

  factory HabitLogModel.fromRow(QueryRow row) => HabitLogModel(
        id: row.readInt('id'),
        habitId: row.readInt('habit_id'),
        dateKey: row.readString('date_key'),
        completedAt: row.readString('completed_at'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'habit_id': habitId,
        'date_key': dateKey,
        'completed_at': completedAt,
      };

  factory HabitLogModel.fromJson(Map<String, dynamic> json) => HabitLogModel(
        id: (json['id'] as num).toInt(),
        habitId: (json['habit_id'] as num).toInt(),
        dateKey: json['date_key'] as String,
        completedAt: json['completed_at'] as String,
      );
}

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.note,
    required this.transactedAt,
    required this.createdAt,
  });

  static const Set<String> types = <String>{'expense', 'income'};

  final int id;
  final int amount;
  final String type;
  final String categoryId;
  final String? note;
  final String transactedAt;
  final String createdAt;

  factory TransactionModel.fromRow(QueryRow row) => TransactionModel(
        id: row.readInt('id'),
        amount: row.readInt('amount'),
        type: row.readString('type'),
        categoryId: row.readString('category_id'),
        note: row.readNullable<String>('note'),
        transactedAt: row.readString('transacted_at'),
        createdAt: row.readString('created_at'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'note': note,
        'transacted_at': transactedAt,
        'created_at': createdAt,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: (json['id'] as num).toInt(),
        amount: (json['amount'] as num).toInt(),
        type: json['type'] as String,
        categoryId: json['category_id'] as String,
        note: json['note'] as String?,
        transactedAt: json['transacted_at'] as String,
        createdAt: json['created_at'] as String,
      );
}

class BillModel {
  const BillModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDay,
    this.lastPaidJalaliMonth,
    required this.createdAt,
  });

  final int id;
  final String title;
  final int amount;
  final int dueDay;
  final String? lastPaidJalaliMonth;
  final String createdAt;

  factory BillModel.fromRow(QueryRow row) => BillModel(
        id: row.readInt('id'),
        title: row.readString('title'),
        amount: row.readInt('amount'),
        dueDay: row.readInt('due_day'),
        lastPaidJalaliMonth: row.readNullable<String>('last_paid_jalali_month'),
        createdAt: row.readString('created_at'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'amount': amount,
        'due_day': dueDay,
        'last_paid_jalali_month': lastPaidJalaliMonth,
        'created_at': createdAt,
      };

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        id: (json['id'] as num).toInt(),
        title: json['title'] as String,
        amount: (json['amount'] as num).toInt(),
        dueDay: (json['due_day'] as num).toInt(),
        lastPaidJalaliMonth: json['last_paid_jalali_month'] as String?,
        createdAt: json['created_at'] as String,
      );
}

class JournalModel {
  const JournalModel({
    required this.id,
    required this.dateKey,
    required this.moodScore,
    required this.energyScore,
    required this.tagsJson,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String dateKey;
  final int moodScore;
  final int energyScore;
  final String tagsJson;
  final String content;
  final String createdAt;
  final String updatedAt;

  factory JournalModel.fromRow(QueryRow row) => JournalModel(
        id: row.readInt('id'),
        dateKey: row.readString('date_key'),
        moodScore: row.readInt('mood_score'),
        energyScore: row.readInt('energy_score'),
        tagsJson: row.readString('tags_json'),
        content: row.readString('content'),
        createdAt: row.readString('created_at'),
        updatedAt: row.readString('updated_at'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'date_key': dateKey,
        'mood_score': moodScore,
        'energy_score': energyScore,
        'tags_json': tagsJson,
        'content': content,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  factory JournalModel.fromJson(Map<String, dynamic> json) => JournalModel(
        id: (json['id'] as num).toInt(),
        dateKey: json['date_key'] as String,
        moodScore: (json['mood_score'] as num).toInt(),
        energyScore: (json['energy_score'] as num).toInt(),
        tagsJson: json['tags_json'] as String,
        content: json['content'] as String,
        createdAt: json['created_at'] as String,
        updatedAt: json['updated_at'] as String,
      );
}

class SettingsModel {
  const SettingsModel({
    this.id = 1,
    this.userName,
    this.themeMode = 'dark',
    this.monthlyBudget,
    this.biometricLockEnabled = false,
    this.dailyReminderTime,
    this.onboardingCompleted = false,
    required this.updatedAt,
  });

  final int id;
  final String? userName;
  final String themeMode;
  final int? monthlyBudget;
  final bool biometricLockEnabled;
  final String? dailyReminderTime;
  final bool onboardingCompleted;
  final String updatedAt;

  SettingsModel copyWith({
    String? userName,
    String? themeMode,
    int? monthlyBudget,
    bool? biometricLockEnabled,
    String? dailyReminderTime,
    bool? onboardingCompleted,
  }) =>
      SettingsModel(
        id: id,
        userName: userName ?? this.userName,
        themeMode: themeMode ?? this.themeMode,
        monthlyBudget: monthlyBudget ?? this.monthlyBudget,
        biometricLockEnabled:
            biometricLockEnabled ?? this.biometricLockEnabled,
        dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
        onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
        updatedAt: updatedAt,
      );

  factory SettingsModel.fromRow(QueryRow row) => SettingsModel(
        id: row.readInt('id'),
        userName: row.readNullable<String>('user_name'),
        themeMode: row.readString('theme_mode'),
        monthlyBudget: row.readNullable<int>('monthly_budget'),
        biometricLockEnabled:
            ModelParsers.boolAt(row, 'biometric_lock_enabled'),
        dailyReminderTime: row.readNullable<String>('daily_reminder_time'),
        onboardingCompleted: ModelParsers.boolAt(row, 'onboarding_completed'),
        updatedAt: row.readString('updated_at'),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'user_name': userName,
        'theme_mode': themeMode,
        'monthly_budget': monthlyBudget,
        'biometric_lock_enabled': biometricLockEnabled ? 1 : 0,
        'daily_reminder_time': dailyReminderTime,
        'onboarding_completed': onboardingCompleted ? 1 : 0,
        'updated_at': updatedAt,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        id: (json['id'] as num?)?.toInt() ?? 1,
        userName: json['user_name'] as String?,
        themeMode: json['theme_mode'] as String? ?? 'dark',
        monthlyBudget: (json['monthly_budget'] as num?)?.toInt(),
        biometricLockEnabled: json['biometric_lock_enabled'] == 1,
        dailyReminderTime: json['daily_reminder_time'] as String?,
        onboardingCompleted: json['onboarding_completed'] == 1,
        updatedAt: json['updated_at'] as String,
      );
}
