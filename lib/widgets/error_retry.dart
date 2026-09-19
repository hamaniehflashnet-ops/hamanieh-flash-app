import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;
  const ErrorRetry({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off, size: 48, color: AppColors.textGrey),
            const SizedBox(height: 12),
            const Text(
              'Connexion impossible pour le moment.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textGrey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
