import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const String _channelId = 'smart_parking_alerts';
  static const String _channelName = 'Smart Parking Alerts';

  static const AndroidNotificationChannel _channel =
  AndroidNotificationChannel(
    _channelId,
    _channelName,
    description: 'Notifications for Smart Parking System',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    tz.initializeTimeZones();

    try {
      tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    } catch (_) {}

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(_channel);

    await androidImplementation?.requestNotificationsPermission();
  }

  void _onNotificationTapped(NotificationResponse response) {}

  Future<void> showBookingConfirmationNotification({
    required String slotName,
    required String locationName,
    required DateTime entryTime,
    required DateTime exitTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for Smart Parking System',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final entry = _formatTime(entryTime);
    final exit = _formatTime(exitTime);

    await _plugin.show(
      id: 1001,
      title: 'Booking Confirmed',
      body:
      '$slotName at $locationName has been booked. Entry: $entry, Exit: $exit.',
      notificationDetails: const NotificationDetails(
        android: androidDetails,
      ),
    );
  }

  Future<void> scheduleSessionExpiryNotification({
    required int notificationId,
    required String slotName,
    required DateTime exitTime,
    int minutesBefore = 15,
  }) async {
    final notificationTime =
    exitTime.subtract(Duration(minutes: minutesBefore));

    final now = DateTime.now();

    if (!notificationTime.isAfter(now)) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(
      notificationTime,
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for Smart Parking System',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: 'Parking Session Ending',
      body:
      'Your parking session for $slotName will expire in $minutesBefore minutes.',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> showBookingStatusChangedNotification({
    required String slotName,
    required String status,
    String? message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for Smart Parking System',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    final body = message ?? '$slotName status changed to $status.';

    await _plugin.show(
      id: 1003,
      title: 'Booking Status Updated',
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
      ),
    );
  }

  Future<void> showParkingAvailableNotification({
    String title = 'Parking Available',
    String body = 'A parking slot is now available nearby.',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for Smart Parking System',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id: 1004,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
      ),
    );
  }

  Future<void> showSessionExpiryNotification({
    String title = 'Parking Session',
    String body = 'Your parking session is nearing its expiry time.',
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for Smart Parking System',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _plugin.show(
      id: 1005,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: androidDetails,
      ),
    );
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;

    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}