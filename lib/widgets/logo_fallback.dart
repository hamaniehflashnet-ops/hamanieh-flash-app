import 'package:flutter/material.dart';

/// Affiché à la place d'une image d'article/vidéo/photo qui n'a pas pu être
/// téléchargée (site source qui bloque, image supprimée, etc.).
class LogoFallback extends StatelessWidget {
  final double? width;
  final double? height;
  const LogoFallback({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Colors.black,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(6),
      child: Image.asset(
        'assets/images/logo.jpg',
        fit: BoxFit.contain,
      ),
    );
  }
}
