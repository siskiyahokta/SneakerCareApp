import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sneaker_care_app/services/api_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'sneakimy_order_channel',
    'Update Pesanan Sneakimy',
    description: 'Notifikasi perubahan status pesanan Sneakimy Care.',
    importance: Importance.high,
  );

  static bool _initialized = false;
  static String? _lastEmail;
  static String? _lastName;
  static String? _lastRole;

  static Future<void> initialize() async {
    if (_initialized) return;

    await _requestPermission();
    await _setupLocalNotifications();
    _listenForegroundMessages();
    _listenNotificationTap();

    _initialized = true;
  }

  static Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM permission: ${settings.authorizationStatus}');
  }

  static Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // flutter_local_notifications versi baru pakai named parameter `settings`.
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Local notification tapped: ${response.payload}');
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  static void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('FCM foreground data: ${message.data}');
      await showLocalNotification(message);
    });
  }

  static void _listenNotificationTap() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('FCM opened from notification: ${message.data}');
    });
  }

  static Future<void> showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ??
        message.data['title']?.toString() ??
        'Sneakimy Care';
    final body = notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString() ??
        'Ada update pesanan baru.';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    // flutter_local_notifications versi baru pakai named parameter.
    await _localNotifications.show(
      id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 2147483647,
      title: title,
      body: body,
      notificationDetails: details,
      payload: message.data.toString(),
    );
  }

  static Future<String?> getToken() async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM TOKEN SNEAKIMY: $token');
      return token;
    } catch (e) {
      debugPrint('Gagal mengambil FCM token: $e');
      return null;
    }
  }

  static Future<void> registerDeviceToken({
    required String customerEmail,
    required String customerName,
    required String role,
  }) async {
    if (customerEmail.trim().isEmpty) return;

    _lastEmail = customerEmail.trim();
    _lastName = customerName.trim();
    _lastRole = role.trim();

    final token = await getToken();
    if (token == null || token.isEmpty) return;

    await ApiService.saveFcmToken(
      customerEmail: customerEmail,
      customerName: customerName,
      fcmToken: token,
      role: role,
      platform: _platformName(),
    );

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      if (_lastEmail == null || _lastEmail!.isEmpty) return;

      await ApiService.saveFcmToken(
        customerEmail: _lastEmail!,
        customerName: _lastName ?? '',
        fcmToken: newToken,
        role: _lastRole ?? 'customer',
        platform: _platformName(),
      );
    });
  }

  static String _platformName() {
    if (kIsWeb) return 'web';

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
