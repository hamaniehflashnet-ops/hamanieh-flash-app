import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';
import 'article_detail_screen.dart';
import '../widgets/error_retry.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Article>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = ApiService.instance.getArticles();
  }

  Future<void> _refresh() async {
    setState(() => _articlesFuture = ApiService.instance.getArticles());
    await _articlesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Article>>(
          future: _articlesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ErrorRetry(onRetry: _refresh);
            }
            final articles = snapshot.data ?? [];
            if (articles.isEmpty) {
              return const Center(child: Text('Aucune actualité pour le moment.'));
            }
            final featured = articles.first;
            final rest = articles.skip(1).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // À la une
                GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: featured))),
                  child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: featured.imageUrl,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) => Container(height: 180, color: Colors.grey[300]),
                      ),
                      Positioned(
                        left: 0, right: 0, bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter, end: Alignment.topCenter,
                              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                color: AppColors.accentRed,
                                child: const Text('À LA UNE', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              const SizedBox(height: 4),
                              Text(featured.title,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Dernières actualités', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...rest.map((a) => _ArticleTile(article: a)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final Article article;
  const _ArticleTile({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article))),
        child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: article.imageUrl, width: 70, height: 70, fit: BoxFit.cover,
                errorWidget: (c, u, e) => Container(width: 70, height: 70, color: Colors.grey[300]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.category.toUpperCase(),
                      style: const TextStyle(color: AppColors.secondaryBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(timeago.format(article.publishedAt, locale: 'fr'),
                      style: const TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
