import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'services/notification_service.dart';

/// Doit rester une fonction top-level (en dehors de toute classe) : c'est
/// une contrainte de Firebase, car elle peut être exécutée dans un isolate
/// séparé quand l'appli est totalement fermée.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.firebaseBackgroundHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    await NotificationService.instance.init();
  } catch (e) {
    // Si google-services.json n'est pas encore configuré, l'appli continue
    // de fonctionner normalement (juste sans notifications push) plutôt
    // que de planter au démarrage.
    debugPrint('Firebase non initialisé : $e');
  }
  runApp(const HamaniehFlashApp());
}

class HamaniehFlashApp extends StatelessWidget {
  const HamaniehFlashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hamanieh Flash.net',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
