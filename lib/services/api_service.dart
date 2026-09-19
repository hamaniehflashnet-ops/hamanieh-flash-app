import 'dart:async';
import 'package:dio/dio.dart';
import '../models/models.dart';

/// Point d'entrée unique vers votre backend.
class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  // Domaine réel du site + dossier /api où sont déposés les scripts PHP JSON
  static const String baseUrl = 'https://hamanieh-flash.net/api';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 12),
  ));

  /// Exécute [request] et réessaie automatiquement en cas d'échec réseau
  /// (utile juste après le démarrage de l'app, quand la connexion n'est
  /// pas encore complètement disponible sur certains téléphones).
  Future<T> _withRetry<T>(Future<T> Function() request, {int attempts = 3}) async {
    DioException? lastError;
    for (var i = 0; i < attempts; i++) {
      try {
        return await request();
      } on DioException catch (e) {
        lastError = e;
        final isNetworkIssue = e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown;
        if (!isNetworkIssue || i == attempts - 1) rethrow;
        await Future.delayed(Duration(milliseconds: 800 * (i + 1)));
      }
    }
    throw lastError!;
  }

  // ---- Actualités ----
  Future<List<Article>> getArticles({String category = 'toutes'}) {
    return _withRetry(() async {
      final res = await _dio.get('/articles.php', queryParameters: {'category': category});
      return (res.data as List).map((e) => Article.fromJson(e)).toList();
    });
  }

  Future<Article> getArticleDetail(String slug) {
    return _withRetry(() async {
      final res = await _dio.get('/article_detail.php', queryParameters: {'slug': slug});
      return Article.fromJson(res.data);
    });
  }

  // ---- Radio ----
  Future<String> getRadioStreamUrl() {
    return _withRetry(() async {
      final res = await _dio.get('/radio.php', queryParameters: {'action': 'stream-url'});
      return res.data['url'];
    });
  }

  Future<List<RadioProgram>> getRadioSchedule() {
    return _withRetry(() async {
      final res = await _dio.get('/radio.php', queryParameters: {'action': 'schedule'});
      return (res.data as List).map((e) => RadioProgram.fromJson(e)).toList();
    });
  }

  // ---- Vidéos / TV ----
  Future<List<VideoItem>> getVideos() {
    return _withRetry(() async {
      final res = await _dio.get('/videos.php');
      return (res.data as List).map((e) => VideoItem.fromJson(e)).toList();
    });
  }

  // ---- Événements ----
  Future<List<EventItem>> getEvents({String filter = 'tous'}) {
    return _withRetry(() async {
      final res = await _dio.get('/events.php', queryParameters: {'filter': filter});
      return (res.data as List).map((e) => EventItem.fromJson(e)).toList();
    });
  }

  // ---- Photos ----
  Future<List<PhotoItem>> getPhotos({String category = 'tous'}) {
    return _withRetry(() async {
      final res = await _dio.get('/photos.php', queryParameters: {'category': category});
      return (res.data as List).map((e) => PhotoItem.fromJson(e)).toList();
    });
  }

  // ---- Contact ----
  Future<void> sendContactRequest(Map<String, dynamic> data) {
    return _withRetry(() async {
      await _dio.post('/contact.php', data: data);
    });
  }
}
