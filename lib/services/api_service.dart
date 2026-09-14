import 'package:dio/dio.dart';
import '../models/models.dart';

/// Point d'entrée unique vers votre backend.
/// ⚠️ Remplacez [baseUrl] par l'URL réelle de votre API existante.
class ApiService {
  ApiService._internal();
  static final ApiService instance = ApiService._internal();

  // Domaine réel du site + dossier /api où sont déposés les scripts PHP JSON
  // (voir dossier hamanieh_flash_api fourni séparément à installer sur le serveur)
  static const String baseUrl = 'https://hamanieh-flash.net/api';

  final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // ---- Actualités ----
  Future<List<Article>> getArticles({String category = 'toutes'}) async {
    final res = await _dio.get('/articles.php', queryParameters: {'category': category});
    return (res.data as List).map((e) => Article.fromJson(e)).toList();
  }

  Future<Article> getArticleDetail(String slug) async {
    final res = await _dio.get('/article_detail.php', queryParameters: {'slug': slug});
    return Article.fromJson(res.data);
  }

  // ---- Radio ----
  Future<String> getRadioStreamUrl() async {
    final res = await _dio.get('/radio.php', queryParameters: {'action': 'stream-url'});
    return res.data['url'];
  }

  Future<List<RadioProgram>> getRadioSchedule() async {
    final res = await _dio.get('/radio.php', queryParameters: {'action': 'schedule'});
    return (res.data as List).map((e) => RadioProgram.fromJson(e)).toList();
  }

  // ---- Vidéos / TV ----
  Future<List<VideoItem>> getVideos() async {
    final res = await _dio.get('/videos.php');
    return (res.data as List).map((e) => VideoItem.fromJson(e)).toList();
  }

  // ---- Événements ----
  Future<List<EventItem>> getEvents({String filter = 'tous'}) async {
    final res = await _dio.get('/events.php', queryParameters: {'filter': filter});
    return (res.data as List).map((e) => EventItem.fromJson(e)).toList();
  }

  // ---- Photos ----
  Future<List<PhotoItem>> getPhotos({String category = 'tous'}) async {
    final res = await _dio.get('/photos.php', queryParameters: {'category': category});
    return (res.data as List).map((e) => PhotoItem.fromJson(e)).toList();
  }

  // ---- Contact ----
  Future<void> sendContactRequest(Map<String, dynamic> data) async {
    await _dio.post('/contact.php', data: data);
  }
}
