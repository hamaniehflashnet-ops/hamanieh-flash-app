import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'radio_screen.dart';
import 'news_screen.dart';
import 'videos_screen.dart';
import 'more_menu_screen.dart';

/// Structure globale : barre de navigation en bas avec 5 onglets
/// (Accueil, Radio, Actualités, Vidéos, Plus) — le "Plus" donne accès
/// à Événements, Photos, Contact et Notifications.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    RadioScreen(),
    NewsScreen(),
    VideosScreen(),
    MoreMenuScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Accueil'),
    BottomNavigationBarItem(icon: Icon(Icons.radio_outlined), activeIcon: Icon(Icons.radio), label: 'Radio'),
    BottomNavigationBarItem(icon: Icon(Icons.article_outlined), activeIcon: Icon(Icons.article), label: 'Actualités'),
    BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle), label: 'Vidéos'),
    BottomNavigationBarItem(icon: Icon(Icons.more_horiz), activeIcon: Icon(Icons.more_horiz), label: 'Plus'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _navItems,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
