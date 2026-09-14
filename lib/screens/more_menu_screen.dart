import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';
import 'events_screen.dart';
import 'photos_screen.dart';
import 'contact_screen.dart';
import 'notifications_screen.dart';

class MoreMenuScreen extends StatelessWidget {
  const MoreMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _MenuEntry('Événements', Icons.event, (ctx) => const EventsScreen()),
      _MenuEntry('Photos', Icons.photo_library, (ctx) => const PhotosScreen()),
      _MenuEntry('Contact & Publicité', Icons.campaign, (ctx) => const ContactScreen()),
      _MenuEntry('Notifications', Icons.notifications, (ctx) => const NotificationsScreen()),
    ];

    return Scaffold(
      appBar: const HFAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Plus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...items.map((item) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(item.icon, color: AppColors.secondaryBlue),
                  title: Text(item.title),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: item.builder),
                  ),
                ),
              )),
          Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.share, color: AppColors.secondaryBlue),
              title: const Text('Partager l\'application'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Share.share('Découvrez Hamanieh Flash.net ! https://hamanieh-flash.net'),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuEntry {
  final String title;
  final IconData icon;
  final WidgetBuilder builder;
  _MenuEntry(this.title, this.icon, this.builder);
}
