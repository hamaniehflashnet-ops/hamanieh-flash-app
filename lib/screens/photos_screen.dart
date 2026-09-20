import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/hf_app_bar.dart';
import '../widgets/error_retry.dart';
import '../utils/image_headers.dart';
import '../widgets/logo_fallback.dart';

class PhotosScreen extends StatefulWidget {
  const PhotosScreen({super.key});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final Map<String, String> _categories = {
    'Tous': 'tous',
    'Politique': 'politique',
    'Économie': 'economie',
    'Société': 'societe',
  };
  String _selected = 'Tous';
  late Future<List<PhotoItem>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _photosFuture = ApiService.instance.getPhotos(category: _categories[_selected]!);
  }

  void _selectCategory(String c) {
    setState(() {
      _selected = c;
      _photosFuture = ApiService.instance.getPhotos(category: _categories[c]!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HFAppBar(),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Photos des événements', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _categories.keys.map((c) {
                final isSelected = c == _selected;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: isSelected,
                    selectedColor: AppColors.secondaryBlue,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textDark),
                    onSelected: (_) => _selectCategory(c),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: FutureBuilder<List<PhotoItem>>(
              future: _photosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return ErrorRetry(onRetry: () => _selectCategory(_selected));
                }
                final photos = snapshot.data ?? [];
                if (photos.isEmpty) {
                  return const Center(child: Text('Aucune photo dans cette catégorie.'));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: photos[i].imageUrl,
                      httpHeaders: kImageHeaders,
                      fit: BoxFit.cover,
                      errorWidget: (c, u, e) => const LogoFallback(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
