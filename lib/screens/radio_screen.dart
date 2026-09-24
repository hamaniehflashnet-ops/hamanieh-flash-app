import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';
import 'radio_schedule_screen.dart';

/// Lecture de la radio via une page HTML jouée dans une WebView plutôt que
/// via un lecteur audio natif (just_audio/ExoPlayer). Les flux Shoutcast de
/// ce serveur (statut "ICY 200 OK" non standard, redirections) posent
/// souvent problème à ExoPlayer alors qu'ils se lisent sans souci dans un
/// vrai navigateur (Chrome) — la WebView utilise le même moteur, donc le
/// même comportement fiable.
class RadioScreen extends StatefulWidget {
  const RadioScreen({super.key});

  @override
  State<RadioScreen> createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  static const String _fallbackStreamUrl =
      'http://ecmanager5.pro-fhi.net:2870/;?type=http';

  late final WebViewController _controller;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _pageReady = false;
  double _volume = 0.8;
  String? _nowPlaying;
  String? _streamUrl;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            _pageReady = true;
            _setJsVolume(_volume);
          },
        ),
      );
    _loadNowPlaying();
    _initStream();
  }

  Future<void> _initStream() async {
    String? url;
    try {
      url = await ApiService.instance.getRadioStreamUrl();
    } catch (_) {
      // ignoré : on retombe sur l'URL de secours ci-dessous.
    }
    _streamUrl = (url == null || url.trim().isEmpty) ? _fallbackStreamUrl : url;

    final html =
        '''
<!DOCTYPE html>
<html>
<body style="margin:0;background:#000;">
  <audio id="player" src="${_streamUrl!.replaceAll('"', '&quot;')}" preload="none"></audio>
</body>
</html>
''';
    await _controller.loadHtmlString(html);
  }

  Future<void> _loadNowPlaying() async {
    try {
      final title = await ApiService.instance.getNowPlaying();
      if (mounted) setState(() => _nowPlaying = title);
    } catch (_) {
      // Silencieux : ce n'est qu'une info d'ambiance, pas bloquant.
    }
  }

  Future<void> _setJsVolume(double v) async {
    if (!_pageReady) return;
    try {
      await _controller.runJavaScript(
        "document.getElementById('player').volume = $v;",
      );
    } catch (_) {}
  }

  Future<void> _play() async {
    if (_isPlaying || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      if (!_pageReady) {
        // La page HTML n'a pas fini de charger : on réessaie l'init une fois.
        await _initStream();
        await Future.delayed(const Duration(milliseconds: 400));
      }
      await _controller.runJavaScript("document.getElementById('player').play();");
      setState(() {
        _isPlaying = true;
        _isLoading = false;
      });
      _loadNowPlaying();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Impossible de démarrer la radio : $e')),
        );
      }
    }
  }

  Future<void> _stop() async {
    // On coupe le flux (pause + retour à 0) plutôt qu'une simple pause :
    // pour une radio en direct, une pause laisse parfois l'audio déjà
    // mis en mémoire tampon continuer quelques secondes.
    try {
      await _controller.runJavaScript(
        "var p = document.getElementById('player'); p.pause(); p.currentTime = 0;",
      );
    } catch (_) {}
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HFAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // WebView invisible (1x1) : elle ne sert qu'à faire jouer l'audio
          // avec le même moteur que Chrome, elle n'affiche rien à l'écran.
          SizedBox(
            width: 1,
            height: 1,
            child: WebViewWidget(controller: _controller),
          ),

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
                          _setJsVolume(v);
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
