import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';

/// Écran listant les notifications reçues (alimenté par Firebase Cloud Messaging).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: remplacer par la vraie liste stockée localement à réception des push FCM
    final notifications = <Map<String, String>>[
      {
        'title': 'Dernières infos !',
        'body': "Côte d'Ivoire : le gouvernement annonce de nouvelles mesures pour la jeunesse.",
        'time': 'Maintenant',
      },
    ];

    return Scaffold(
      appBar: const HFAppBar(),
      body: notifications.isEmpty
          ? const Center(child: Text('Aucune notification pour le moment.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = notifications[i];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primaryBlue,
                      child: Icon(Icons.notifications, color: Colors.white),
                    ),
                    title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(n['body']!),
                    trailing: Text(n['time']!, style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                  ),
                );
              },
            ),
    );
  }
}
