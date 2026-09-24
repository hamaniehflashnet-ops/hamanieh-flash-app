import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';

/// Écran listant les notifications reçues (alimenté par Firebase Cloud Messaging),
/// stockées localement sur l'appareil au fil de leur réception.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await NotificationService.instance.getHistory();
    if (mounted) {
      setState(() {
        _notifications = history;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _notifications.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('Aucune notification pour le moment.')),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: AppColors.primaryBlue,
                              child: Icon(Icons.notifications, color: Colors.white),
                            ),
                            title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(n.body),
                            trailing: Text(
                              timeago.format(n.receivedAt, locale: 'fr'),
                              style: const TextStyle(color: AppColors.textGrey, fontSize: 11),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
