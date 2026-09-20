import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/more_menu_screen.dart';
import '../screens/notifications_screen.dart';

/// AppBar réutilisée sur tous les écrans : menu ☰ (ou retour ←), logo, cloche 🔔
class HFAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onNotificationTap;

  const HFAppBar({super.key, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return AppBar(
      leading: canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            )
          : IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MoreMenuScreen()),
              ),
            ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentRed,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'HAMANIEH',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          const SizedBox(width: 4),
          const Text('FLASH.net', style: TextStyle(color: AppColors.primaryBlue, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: onNotificationTap ??
              () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
