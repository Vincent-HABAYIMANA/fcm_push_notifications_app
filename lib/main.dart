import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';

// Background message handler — must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase already initialized (background)");
  }

  debugPrint('📬 Background message received: ${message.messageId}');
}

// Local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ SAFE Firebase initialization (NO DUPLICATE ERROR)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase already initialized");
  }

  // Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Local notifications setup
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Push Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationScreen(),
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _deviceToken = 'Fetching token...';
  final List<Map<String, String>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  Future<void> _initFCM() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Permission: ${settings.authorizationStatus}');

    // Get token
    final token = await messaging.getToken();
    setState(() {
      _deviceToken = token ?? 'Unable to get token';
    });
    debugPrint('📱 Token: $token');

    // Token refresh
    messaging.onTokenRefresh.listen((newToken) {
      setState(() => _deviceToken = newToken);
      debugPrint('🔄 Token refreshed: $newToken');
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _addNotification(message);
      _showLocalNotification(message);
      _showPopupDialog(message);
    });

    // Background open
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _addNotification(message);
    });

    // App opened from terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _addNotification(initialMessage);
    }
  }

  void _addNotification(RemoteMessage message) {
    setState(() {
      _notifications.insert(0, {
        'title': message.notification?.title ?? '(No title)',
        'body': message.notification?.body ?? '(No body)',
        'time': DateTime.now().toString().substring(0, 19),
      });
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'fcm_channel',
      'FCM Notifications',
      channelDescription: 'Channel for FCM push notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification?.title,
      message.notification?.body,
      details,
    );
  }

  void _showPopupDialog(RemoteMessage message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.notifications_active,
            color: Colors.deepPurple, size: 36),
        title: Text(message.notification?.title ?? 'New Notification'),
        content: Text(message.notification?.body ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('FCM Push Notifications'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Token Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Device Token",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(_deviceToken),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Notifications",
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 10),

            if (_notifications.isEmpty)
              const Text("No notifications yet")
            else
              ..._notifications.map((n) => ListTile(
                    title: Text(n['title']!),
                    subtitle: Text(n['body']!),
                  )),
          ],
        ),
      ),
    );
  }
}