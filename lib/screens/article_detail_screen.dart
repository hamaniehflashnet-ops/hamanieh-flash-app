import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/image_headers.dart';

/// Écran de détail, ouvert avec l'article déjà connu (depuis une liste)
/// puis complété via l'API pour récupérer le contenu complet (`content`).
class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late Future<Article> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = widget.article.slug != null
        ? ApiService.instance.getArticleDetail(widget.article.slug!)
        : Future.value(widget.article);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => Share.share(widget.article.title),
          ),
        ],
      ),
      body: FutureBuilder<Article>(
        future: _detailFuture,
        builder: (context, snapshot) {
          final article = snapshot.data ?? widget.article;
          final isLoadingContent = snapshot.connectionState == ConnectionState.waiting;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CachedNetworkImage(
                  imageUrl: article.imageUrl,
                  httpHeaders: kImageHeaders,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (c, u, e) => Container(height: 220, color: Colors.grey[300]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBlue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(article.category.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Text(article.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(timeago.format(article.publishedAt, locale: 'fr'),
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      const Divider(height: 28),
                      if (isLoadingContent)
                        const Center(child: CircularProgressIndicator())
                      else
                        Text(
                          article.content?.isNotEmpty == true
                              ? article.content!
                              : 'Contenu non disponible.',
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
