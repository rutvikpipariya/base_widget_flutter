import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Shows local notifications from one pre-configured channel.
///
/// Configure the icon and channel once at start-up, then fire notifications
/// from anywhere:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await BaseNotificationService.init(
///     androidIcon: '@mipmap/ic_launcher',
///     channelId: 'reminders',
///     channelName: 'Appointment reminders',
///   );
///   runApp(const MyApp());
/// }
///
/// await BaseNotificationService.show(
///   title: 'Appointment tomorrow',
///   body: '10:30 with Dr. Patel',
/// );
/// ```
///
/// Declare the platform setup yourself — the notification icon drawable on
/// Android and, from Android 13, the `POST_NOTIFICATIONS` permission. See the
/// `flutter_local_notifications` README for the full per-platform setup.
class BaseNotificationService {
  const BaseNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static String _channelId = 'default_channel';
  static String _channelName = 'Notifications';
  static String? _channelDescription;
  static int _autoId = 0;

  /// The plugin instance, for scheduling, cancelling and tap callbacks.
  static FlutterLocalNotificationsPlugin get plugin => _plugin;

  /// Initialises the plugin and remembers the channel used by [show].
  ///
  /// [androidIcon] is a drawable resource in your Android project, usually
  /// `'@mipmap/ic_launcher'`. [channelId] identifies the channel to Android;
  /// changing it after release creates a *new* channel, leaving the old one
  /// visible in system settings, so pick one and keep it.
  ///
  /// Set [requestPermissions] to false to ask later at a moment that makes
  /// sense to the user — a cold prompt on first launch is usually declined.
  static Future<void> init({
    String androidIcon = '@mipmap/ic_launcher',
    String channelId = 'default_channel',
    String channelName = 'Notifications',
    String? channelDescription,
    bool requestPermissions = true,
    DidReceiveNotificationResponseCallback? onTap,
  }) async {
    _channelId = channelId;
    _channelName = channelName;
    _channelDescription = channelDescription;

    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings(androidIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: requestPermissions,
          requestBadgePermission: requestPermissions,
          requestSoundPermission: requestPermissions,
        ),
      ),
      onDidReceiveNotificationResponse: onTap,
    );

    if (requestPermissions) {
      await BaseNotificationService.requestPermissions();
    }
  }

  /// Asks the user for notification permission.
  ///
  /// Call this when [init] was given `requestPermissions: false`, at a point
  /// where the user understands why you need it.
  static Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  /// Shows a notification on the channel configured in [init].
  ///
  /// [id] identifies the notification: showing again with the same id
  /// *replaces* the earlier one. Leave it null for a fresh id each time.
  /// [payload] is handed to the `onTap` callback given to [init].
  static Future<void> show({
    required String title,
    required String body,
    int? id,
    String? payload,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) => _plugin.show(
    id: id ?? _autoId++,
    title: title,
    body: body,
    payload: payload,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: importance,
        priority: priority,
      ),
      iOS: const DarwinNotificationDetails(),
    ),
  );

  /// Removes the notification with [id].
  static Future<void> cancel(int id) => _plugin.cancel(id: id);

  /// Removes every notification this app has posted.
  static Future<void> cancelAll() => _plugin.cancelAll();
}
