import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madaar/core/notifications/notification_service.dart';

final Provider<NotificationService> notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService.instance);
