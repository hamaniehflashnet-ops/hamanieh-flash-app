class Article {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final DateTime publishedAt;
  final String? content;
  final String? slug;

  Article({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.publishedAt,
    this.content,
    this.slug,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      imageUrl: json['image_url'] ?? '',
      category: json['category'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
      content: json['content'],
      slug: json['slug'],
    );
  }
}

class VideoItem {
  final String id;
  final String title;
  final String thumbnailUrl;
  final String youtubeId;
  final String duration;
  final DateTime publishedAt;

  VideoItem({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.youtubeId,
    required this.duration,
    required this.publishedAt,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      youtubeId: json['youtube_id'] ?? '',
      duration: json['duration'] ?? '',
      publishedAt: DateTime.tryParse(json['published_at'] ?? '') ?? DateTime.now(),
    );
  }
}

class EventItem {
  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String? imageUrl;

  EventItem({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    this.imageUrl,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      date: DateTime.tryParse(json['date'] ?? '') ?? DateTime.now(),
      imageUrl: json['image_url'],
    );
  }
}

class PhotoItem {
  final String id;
  final String imageUrl;
  final String albumCategory;

  PhotoItem({
    required this.id,
    required this.imageUrl,
    required this.albumCategory,
  });

  factory PhotoItem.fromJson(Map<String, dynamic> json) {
    return PhotoItem(
      id: json['id'].toString(),
      imageUrl: json['image_url'] ?? '',
      albumCategory: json['album_category'] ?? '',
    );
  }
}

class RadioProgram {
  final String title;
  final String startTime;
  final String endTime;

  RadioProgram({required this.title, required this.startTime, required this.endTime});

  factory RadioProgram.fromJson(Map<String, dynamic> json) {
    return RadioProgram(
      title: json['title'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
    );
  }
}
