import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';
import 'radio_schedule_screen.dart';

class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  double _volume = 0.8;
  String? _nowPlaying;

  @override
  void initState() {
    super.initState();
    _player.setVolume(_volume);
    _loadNowPlaying();
  }

  Future<void> _loadNowPlaying() async {
    try {
      final title = await ApiService.instance.getNowPlaying();
      if (mounted) setState(() => _nowPlaying = title);
    } catch (_) {
      // Silencieux : ce n'est qu'une info d'ambiance, pas bloquant.
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _stop() async {
    // stop() plutôt que pause() : pour un flux radio en direct, pause()
    // laisse parfois l'audio déjà mis en mémoire tampon continuer à jouer
    // quelques secondes. stop() coupe immédiatement.
    await _player.stop();
    if (mounted) setState(() => _isPlaying = false);
  }

  Future<void> _play() async {
    if (_isPlaying || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final url = await ApiService.instance.getRadioStreamUrl();
      if (url == null || url.isEmpty) {
        throw Exception(
          "Aucune URL de flux configurée (réglage 'radio_stream_url' vide dans le back-office).",
        );
      }
      // Certains serveurs de streaming vérifient l'origine de la demande
      // (comme un vrai navigateur) avant d'autoriser l'écoute.
      final headers = {
        'Icy-MetaData': '0',
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Mobile Safari/537.36',
        'Referer': 'https://ecmanager5.pro-fhi.net:2860/',
      };
      await _player.setUrl(url, headers: headers).timeout(const Duration(seconds: 15));
      await _player.play();
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
      _loadNowPlaying();
    } catch (e) {
      await _player.stop();
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
      backgroundColor: AppColors.background,
      appBar: const HFAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bandeau logo + LIVE, façon site web
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/logo.jpg', width: 220, fit: BoxFit.contain),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 8, color: Colors.white),
                      SizedBox(width: 6),
                      Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Carte de lecture
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                const Text("L'actualité sous un autre angle !!!",
                    style: TextStyle(fontStyle: FontStyle.italic, color: AppColors.textGrey)),
                const SizedBox(height: 4),
                const Text('Hamanieh Flash Radio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.circle, size: 10, color: AppColors.liveGreen),
                    const SizedBox(width: 6),
                    const Icon(Icons.circle, size: 10, color: AppColors.accentRed),
                    const SizedBox(width: 8),
                    Text(_nowPlaying ?? 'EN DIRECT',
                        style: const TextStyle(color: AppColors.textGrey, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 20),

                // Deux boutons distincts : Lire et Arrêter
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: (_isLoading || _isPlaying) ? null : _play,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text(
                            'LIRE',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: (_isPlaying && !_isLoading) ? _stop : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentRed,
                            disabledBackgroundColor: AppColors.accentRed.withOpacity(0.4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          icon: const Icon(Icons.stop, color: Colors.white),
                          label: const Text(
                            'ARRÊTER',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Volume
                Row(
                  children: [
                    Icon(_volume == 0 ? Icons.volume_off : Icons.volume_up, color: AppColors.textGrey),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        activeColor: AppColors.primaryBlue,
                        onChanged: (v) {
                          setState(() => _volume = v);
                          _player.setVolume(v);
                        },
                      ),
                    ),
                    SizedBox(
                      width: 42,
                      child: Text('${(_volume * 100).round()}%', style: const TextStyle(color: AppColors.textGrey)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RadioScheduleScreen()),
                  ),
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
    );
  }
}
