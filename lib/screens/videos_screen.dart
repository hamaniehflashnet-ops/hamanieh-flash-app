import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';

class VideosScreen extends StatefulWidget {
  const VideosScreen({super.key});

  @override
  State<VideosScreen> createState() => _VideosScreenState();
}

class _VideosScreenState extends State<VideosScreen> {
  late Future<List<VideoItem>> _videosFuture;

  @override
  void initState() {
    super.initState();
    _videosFuture = ApiService.instance.getVideos();
  }

  void _openVideo(VideoItem video) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: FutureBuilder<List<VideoItem>>(
        future: _videosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final videos = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Hamanieh TV / YouTube', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Nos dernières vidéos', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('Voir tout')),
                ],
              ),
              if (videos.isEmpty) const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Aucune vidéo disponible pour le moment.')),
              ),
              ...videos.map((v) => _VideoTile(video: v, onTap: () => _openVideo(v))),
            ],
          );
        },
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;
  const _VideoTile({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(6),
        leading: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: video.thumbnailUrl, width: 90, height: 60, fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(width: 90, height: 60, color: Colors.grey[300]),
              ),
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 28),
          ],
        ),
        title: Text(video.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Text(timeago.format(video.publishedAt, locale: 'fr')),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final VideoItem video;
  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.video.youtubeId,
      flags: const YoutubePlayerFlags(autoPlay: true),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.video.title)),
      body: YoutubePlayer(controller: _controller),
    );
  }
}
