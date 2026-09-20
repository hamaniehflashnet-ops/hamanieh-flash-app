import 'package:flutter/material.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Permet à la radio de continuer à jouer quand l'app est en arrière-plan,
  // avec une notification affichant les contrôles (lecture/pause).
  await JustAudioBackground.init(
    androidNotificationChannelId: 'net.hamaniehflash.audio',
    androidNotificationChannelName: 'Hamanieh Flash Radio',
    androidNotificationOngoing: true,
  );
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
