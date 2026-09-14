import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
      setState(() => _isPlaying = false);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final url = await ApiService.instance.getRadioStreamUrl();
      await _player.setUrl(url);
      await _player.play();
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de démarrer la radio : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: AppColors.accentRed, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text('EN DIRECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Text('24h/24', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Icon(Icons.mic, color: Colors.white, size: 64),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: _isLoading ? null : _togglePlay,
                    child: Container(
                      width: 72, height: 72,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: _isLoading
                          ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())
                          : Icon(_isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 40, color: AppColors.primaryBlue),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Hamanieh Flash Radio',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const Text('Votre radio, toute la journée', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: ListTile(
                leading: const Icon(Icons.article, color: AppColors.secondaryBlue),
                title: const Text('En ce moment'),
                subtitle: const Text('Journal des nouvelles'),
                trailing: const Icon(Icons.volume_up),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: naviguer vers la grille des programmes complète
                    },
                    icon: const Icon(Icons.grid_view),
                    label: const Text('Grille des\nprogrammes', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Share.share('Écoutez Hamanieh Flash Radio en direct ! https://hamanieh-flash.net');
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Partager'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
