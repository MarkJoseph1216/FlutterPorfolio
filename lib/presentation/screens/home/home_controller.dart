import 'package:flutter/material.dart';

class HomeController {
  HomeController();

  final ScrollController scrollController = ScrollController();

  final heroKey = GlobalKey();
  final aboutKey = GlobalKey();
  final projectsKey = GlobalKey();
  final sideProjectsKey = GlobalKey();
  final skillsKey = GlobalKey();
  final contactKey = GlobalKey();

  List<GlobalKey> get sectionKeys => [
        heroKey,
        aboutKey,
        projectsKey,
        sideProjectsKey,
        skillsKey,
        contactKey,
      ];

  void scrollTo(String section) {
    final key = _keyForSection(section);
    if (key == null) return;
    _navigateTo(key);
  }

  void navigateTo(GlobalKey key) => _navigateTo(key);
  void dispose() => scrollController.dispose();

  GlobalKey? _keyForSection(String section) => switch (section) {
        'about' => aboutKey,
        'projects' => projectsKey,
        'sideprojects' => sideProjectsKey,
        'skills' => skillsKey,
        'contact' => contactKey,
        _ => null,
      };

  void _navigateTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
    );
  }
}
