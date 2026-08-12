import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/models/project_model.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> with TickerProviderStateMixin {
  late final AnimationController _staggeredController;
  late final AnimationController _floatingBarController;

  @override
  void initState() {
    super.initState();

    _staggeredController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _floatingBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _staggeredController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _floatingBarController.forward();
      });
    });
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    _floatingBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double fs = (screenWidth / 375.0).clamp(0.85, 1.25);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_rounded, size: 22 * fs, color: colors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24 * fs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12 * fs),

                      if (widget.project.category != null) ...[
                        Row(
                          children: [
                            Container(width: 6 * fs, height: 6 * fs, decoration: BoxDecoration(color: colors.tvAccent, shape: BoxShape.circle)),
                            SizedBox(width: 8 * fs),
                            Text(widget.project.category!.label.toUpperCase(),
                                style: AppFonts.tvRetro(color: colors.tvAccent, size: 11 * fs, letterSpacing: 2.0, weight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 12 * fs),
                      ],
                      Text(widget.project.title,
                          style: AppFonts.heading(color: colors.textPrimary, size: 34 * fs, weight: FontWeight.bold)),

                      SizedBox(height: 24 * fs),

                      _animateItem(
                        index: 0,
                        child: _buildEditorialMetaBar(colors, fs),
                      ),
                      SizedBox(height: 28 * fs),

                      _animateItem(
                        index: 1,
                        child: _buildHeroMedia(colors, fs),
                      ),
                      SizedBox(height: 36 * fs),

                      _animateItem(
                        index: 2,
                        child: _buildTextSection('ABOUT THE PROJECT', widget.project.description, colors, fs),
                      ),
                      SizedBox(height: 36 * fs),

                      if (widget.project.techStack.isNotEmpty)
                        _animateItem(
                          index: 3,
                          child: _buildTechStack(colors, fs),
                        ),

                      if (widget.project.screenshots != null && widget.project.screenshots!.isNotEmpty) ...[
                        SizedBox(height: 36 * fs),
                        _animateItem(
                          index: 4,
                          child: _buildGallerySection(context, colors, fs),
                        ),
                      ],

                      SizedBox(height: 40 * fs),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _animateItem({required int index, required Widget child}) {
    const staggerDuration = Duration(milliseconds: 200);
    final animationStart = staggerDuration * index;
    const animationDuration = Duration(milliseconds: 700);

    final Animation<double> opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          animationStart.inMilliseconds / _staggeredController.duration!.inMilliseconds,
          (animationStart + animationDuration).inMilliseconds / _staggeredController.duration!.inMilliseconds,
          curve: Curves.easeOut,
        ),
      ),
    );

    final Animation<Offset> slideAnimation = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          animationStart.inMilliseconds / _staggeredController.duration!.inMilliseconds,
          (animationStart + animationDuration).inMilliseconds / _staggeredController.duration!.inMilliseconds,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return FadeTransition(
      opacity: opacityAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }

  Widget _buildEditorialMetaBar(dynamic colors, double fs) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16 * fs),
      decoration: BoxDecoration(border: Border.symmetric(horizontal: BorderSide(color: colors.border.withOpacity(0.6)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _metaColumn('ROLE', widget.project.role ?? 'Lead Developer', colors, fs),
          _metaColumn('YEAR', widget.project.year.isNotEmpty ? widget.project.year : '2024', colors, fs),
          _metaColumn('POSITION', widget.project.index, colors, fs),
        ],
      ),
    );
  }

  Widget _metaColumn(String title, String value, dynamic colors, double fs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppFonts.tvRetro(color: colors.textMuted, size: 9 * fs, letterSpacing: 1.8)),
        SizedBox(height: 4 * fs),
        Text(value, style: AppFonts.label(color: colors.textPrimary, size: 13 * fs, weight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildHeroMedia(dynamic colors, double fs) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: widget.project.thumbnailAsset != null
            ? Image.asset(widget.project.thumbnailAsset!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(colors, fs))
            : _buildPlaceholder(colors, fs),
      ),
    );
  }

  Widget _buildTextSection(String retroTitle, String body, dynamic colors, double fs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(retroTitle, style: AppFonts.tvRetro(color: colors.textMuted, size: 10 * fs, letterSpacing: 2.0)),
        SizedBox(height: 12 * fs),
        Text(body, style: AppFonts.body(color: colors.textPrimary, size: 16 * fs, height: 1.7)),
      ],
    );
  }

  Widget _buildTechStack(dynamic colors, double fs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TECH STACK', style: AppFonts.tvRetro(color: colors.textMuted, size: 10 * fs, letterSpacing: 2.0)),
        SizedBox(height: 14 * fs),
        Wrap(
          spacing: 8 * fs,
          runSpacing: 10 * fs,
          children: widget.project.techStack.map((tech) => _buildMinimalTechBadge(tech, colors, fs)).toList(),
        ),
      ],
    );
  }

  Widget _buildMinimalTechBadge(String tech, dynamic colors, double fs) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12 * fs, vertical: 6 * fs),
      decoration: BoxDecoration(color: colors.surfaceAlt, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.border)),
      child: Text(tech, style: AppFonts.code(color: colors.textPrimary, size: 12 * fs)),
    );
  }

  Widget _buildGallerySection(BuildContext context, dynamic colors, double fs) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('SCREENSHOTS', style: AppFonts.tvRetro(color: colors.textMuted, size: 10 * fs, letterSpacing: 2.0)),
            Text('Tap to expand', style: AppFonts.bodySmall(color: colors.textMuted, size: 12 * fs)),
          ],
        ),
        SizedBox(height: 14 * fs),
        SizedBox(
          height: 260 * fs,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.project.screenshots!.length,
            separatorBuilder: (_, __) => SizedBox(width: 14 * fs),
            itemBuilder: (ctx, index) {
              final String screenshotPath = widget.project.screenshots![index];
              final String heroTag = 'screenshot_${widget.project.index}_$index';

              return SizedBox(
                width: 150 * fs,
                child: _AnimatedGalleryItem(
                  onTap: () => _openFullScreenGallery(context, widget.project.screenshots!, index),
                  screenshot: screenshotPath,
                  heroTag: heroTag,
                  colors: colors,
                  fs: fs,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(dynamic colors, double fs) {
    return Container(color: colors.surfaceAlt, child: Center(child: Text(widget.project.title.isNotEmpty ? widget.project.title[0].toUpperCase() : 'P', style: AppFonts.tvDisplay(color: colors.textMuted, size: 48 * fs))));
  }

  void _openFullScreenGallery(BuildContext context, List<String> screenshots, int initialIndex) {
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      pageBuilder: (context, _, __) => _FullScreenGalleryViewer(
        screenshots: screenshots,
        initialIndex: initialIndex,
        projectId: widget.project.index,
      ),
    ));
  }

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _AnimatedGalleryItem extends StatefulWidget {
  final VoidCallback onTap;
  final String screenshot;
  final String heroTag;
  final dynamic colors;
  final double fs;

  const _AnimatedGalleryItem({
    required this.onTap,
    required this.screenshot,
    required this.heroTag,
    required this.colors,
    required this.fs,
  });

  @override
  State<_AnimatedGalleryItem> createState() => _AnimatedGalleryItemState();
}

class _AnimatedGalleryItemState extends State<_AnimatedGalleryItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: widget.colors.border.withOpacity(0.5))),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Hero(
                  tag: widget.heroTag,
                  child: Image.asset(
                    widget.screenshot,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(width: 150 * widget.fs, color: widget.colors.surfaceAlt, child: Icon(Icons.broken_image_outlined, color: widget.colors.textSecondary)),
                  ),
                ),
                Positioned(right: 8, bottom: 8, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle), child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 16))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedPrimaryButton extends StatefulWidget {
  final String url;
  final dynamic colors;
  final double fs;

  const _AnimatedPrimaryButton({required this.url, required this.colors, required this.fs});

  @override
  State<_AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<_AnimatedPrimaryButton> {
  double _scale = 1.0;

  void _launchUrl() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.98),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: _launchUrl,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14 * widget.fs),
          decoration: BoxDecoration(color: widget.colors.tvAccent, borderRadius: BorderRadius.circular(24)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Visit Website', style: AppFonts.button(color: Colors.white, size: 13 * widget.fs)),
              SizedBox(width: 6 * widget.fs),
              Icon(Icons.north_east_rounded, size: 16 * widget.fs, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _FullScreenGalleryViewer extends StatefulWidget {
  final List<String> screenshots;
  final int initialIndex;
  final String projectId;

  const _FullScreenGalleryViewer({
    required this.screenshots,
    required this.initialIndex,
    required this.projectId,
  });

  @override
  State<_FullScreenGalleryViewer> createState() => _FullScreenGalleryViewerState();
}

class _FullScreenGalleryViewerState extends State<_FullScreenGalleryViewer> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late final AnimationController _uiController;
  late Animation<Offset> _uiSlideAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _uiSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _uiController,
      curve: Curves.easeOutCubic,
    ));
    _uiController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _uiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.92),
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.screenshots.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                final String heroTag = 'screenshot_${widget.projectId}_$index';

                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: Center(
                    child: Hero(
                      tag: heroTag,
                      child: Image.asset(
                        widget.screenshots[index],
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(Icons.broken_image_outlined, color: colors.textSecondary, size: 48),
                      ),
                    ),
                  ),
                );
              },
            ),

            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: FadeTransition(
                opacity: _uiController,
                child: SlideTransition(
                  position: _uiSlideAnimation,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                        child: Text('${(_currentIndex + 1).toString().padLeft(2, '0')} / ${widget.screenshots.length.toString().padLeft(2, '0')}', style: AppFonts.tvRetro(color: Colors.white, size: 11, letterSpacing: 1.5)),
                      ),

                      IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28), onPressed: () => Navigator.of(context).pop()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}