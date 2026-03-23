import 'package:flutter/material.dart';
import 'package:mj_personal_portfolio/presentation/widgets/sections/loading_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/scroll_controller_provider.dart';
import '../../../core/utils/device_utils.dart';
import '../../widgets/common/navbar.dart';
import '../../widgets/common/scroll_progress_bar.dart';
import '../../widgets/effects/cursor_spotlight.dart';
import '../../widgets/effects/ink_ripple_overlay.dart';
import '../../widgets/effects/kanji_background.dart';
import '../../widgets/effects/noise_overlay.dart';
import '../../widgets/sections/about_section.dart';
import '../../widgets/sections/contact_section.dart';
import '../../widgets/sections/footer_section.dart';
import '../../widgets/sections/hero_section.dart';
import '../../widgets/chatbot/chat_bubble.dart';
import '../../widgets/sections/work_section.dart';
import '../../widgets/sections/side_projects_section.dart';
import '../../widgets/sections/skills_section.dart';
import 'home_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final HomeController _ctrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _ctrl = HomeController();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return LoadingScreen(
        onComplete: () => setState(() => _loading = false),
      );
    }

    final mobile = DeviceUtils.isMobile(context);
    final c = AppColors.of(context);

    return InkRippleOverlay(
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: [
            RepaintBoundary(
              child: KanjiBackground(reducedMode: mobile),
            ),
            if (!mobile) const CursorSpotlight(),
            _buildScrollContent(),
            const RepaintBoundary(child: NoiseOverlay()),
            ScrollProgressBar(scrollController: _ctrl.scrollController),
            _buildNavBar(),
            const ChatBubble(),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollContent() {
    return ScrollControllerProvider(
      scrollController: _ctrl.scrollController,
      child: SingleChildScrollView(
        controller: _ctrl.scrollController,
        child: Column(
          children: [
            const SizedBox(height: 56),
            HeroSection(
              key: _ctrl.heroKey,
              onWorkTap: () => _ctrl.navigateTo(_ctrl.projectsKey),
              onContactTap: () => _ctrl.navigateTo(_ctrl.contactKey),
            ),
            AboutSection(key: _ctrl.aboutKey),
            WorkSection(key: _ctrl.projectsKey),
            SkillsSection(key: _ctrl.skillsKey),
            SideProjectsSection(key: _ctrl.sideProjectsKey),
            ContactSection(key: _ctrl.contactKey),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Positioned(
      top: 2,
      left: 0,
      right: 0,
      child: NavBar(
        scrollController: _ctrl.scrollController,
        onNavTap: _ctrl.scrollTo,
      ),
    );
  }
}
