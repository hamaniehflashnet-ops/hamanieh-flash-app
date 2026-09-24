import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Un message de notification reçu, tel qu'affiché dans l'écran
/// "Notifications" de l'appli.
class AppNotification {
  final String title;
  final String body;
  final DateTime receivedAt;

  AppNotification({required this.title, required this.body, required this.receivedAt});

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'receivedAt': receivedAt.toIso8601String(),
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) => AppNotification(
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        receivedAt: DateTime.tryParse(json['receivedAt'] as String? ?? '') ?? DateTime.now(),
      );
}

/// Gère l'inscription aux notifications push (Firebase Cloud Messaging),
/// leur affichage quand l'appli est ouverte, et leur historique local
/// (stocké sur l'appareil, affiché dans NotificationsScreen).
///
/// Toutes les installations de l'appli sont abonnées au topic FCM
/// "all_users" : pour envoyer une notification à tout le monde, il suffit
/// d'envoyer un message au topic "all_users" depuis la console Firebase
/// ou depuis le back-office (API Firebase Admin), sans gérer de tokens
/// par appareil.
class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  static const _storageKey = 'hf_notifications_history';
  static const _topic = 'all_users';
  static const _channelId = 'hf_default_channel';
  static const _channelName = 'Hamanieh Flash';

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  final _historyController = <void Function()>[];

  /// À appeler une seule fois au démarrage de l'appli, après Firebase.initializeApp().
  Future<void> init() async {
    // Affichage des notifications reçues pendant que l'appli est ouverte.
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _localNotifications.initialize(initSettings);

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Actualités et alertes Hamanieh Flash',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Permission (obligatoire à partir d'Android 13 / iOS).
    await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

    // Abonnement au topic commun à tous les utilisateurs.
    await FirebaseMessaging.instance.subscribeToTopic(_topic);

    // Notification reçue pendant que l'appli est au premier plan : Firebase
    // ne l'affiche pas tout seul, il faut la déclencher nous-mêmes.
    FirebaseMessaging.onMessage.listen((message) async {
      await _saveAndShow(message);
    });

    // L'utilisateur tape sur la notification alors que l'appli était en
    // arrière-plan : on l'enregistre aussi dans l'historique.
    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      await _save(message);
    });

    // Appli lancée depuis une notification (était totalement fermée).
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      await _save(initialMessage);
    }
  }

  /// Doit être une fonction top-level ou statique, enregistrée dans main.dart
  /// AVANT runApp(), pour recevoir les notifications quand l'appli est
  /// totalement fermée ou en arrière-plan.
  static Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
    await NotificationService.instance._save(message);
  }

  Future<void> _save(RemoteMessage message) async {
    final title = message.notification?.title ?? 'Hamanieh Flash';
    final body = message.notification?.body ?? '';
    if (body.isEmpty && title.isEmpty) return;
    final history = await getHistory();
    history.insert(0, AppNotification(title: title, body: body, receivedAt: DateTime.now()));
    final trimmed = history.take(100).toList(); // on garde les 100 plus récentes
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(trimmed.map((n) => n.toJson()).toList()));
  }

  Future<void> _saveAndShow(RemoteMessage message) async {
    await _save(message);
    final title = message.notification?.title ?? 'Hamanieh Flash';
    final body = message.notification?.body ?? '';
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(_channelId, _channelName, importance: Importance.high),
      ),
    );
  }

  Future<List<AppNotification>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => AppNotification.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}
