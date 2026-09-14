import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Contact & Publicité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contactez-nous', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone, color: AppColors.secondaryBlue),
                    title: const Text('+225 01 03 57 42 40'),
                    onTap: () => _launch('tel:+225010357420'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone, color: AppColors.secondaryBlue),
                    title: const Text('+225 07 03 22 36 03'),
                    onTap: () => _launch('tel:+225070322360'),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email, color: AppColors.secondaryBlue),
                    title: const Text('contact@hamanieh-flash.com'),
                    onTap: () => _launch('mailto:contact@hamanieh-flash.com'),
                  ),
                  const ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.location_on, color: AppColors.secondaryBlue),
                    title: Text('Abidjan - Côte d\'Ivoire'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Publicité & Partenariat', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Faites la promotion de votre marque sur Hamanieh Flash.net !',
                      style: TextStyle(color: AppColors.textGrey)),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, padding: const EdgeInsets.symmetric(vertical: 14)),
                      onPressed: () {
                        // TODO: ouvrir un formulaire de contact publicitaire (via ApiService.sendContactRequest)
                      },
                      child: const Text('Nous contacter', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
