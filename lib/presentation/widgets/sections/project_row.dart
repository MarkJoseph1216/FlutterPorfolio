import 'package:flutter/material.dart';
import 'package:mj_personal_portfolio/presentation/screens/projects/project_detail_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/models/project_model.dart';

class ProjectRow extends StatefulWidget {
  const ProjectRow({
    super.key,
    required this.project,
    required this.fs,
  });

  final ProjectModel project;
  final double fs;

  @override
  State<ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<ProjectRow> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _expanded = false;
  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;
  bool _hasImageError = false;

  @override
  void initState() {
    super.initState();
    _expandCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 220));
    _expandAnim = CurvedAnimation(parent: _expandCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _expandCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _expandCtrl.forward() : _expandCtrl.reverse();
  }

  void _onViewProject() async {
    final project = widget.project;
    final url = project.urlLink ?? project.playStoreUrl;

    if (url != null && url.isNotEmpty) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    if ((project.thumbnailAsset != null && project.thumbnailAsset!.isNotEmpty) ||
        (project.screenshots != null && project.screenshots!.isNotEmpty)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProjectDetailScreen(project: project),
        ),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No preview available.')),
      );
    }
  }

  Widget _buildThumbnail() {
    final colors = AppColors.of(context);
    final isCompact = ScreenUtils.isCompactMobile(context);
    final size = isCompact ? 50 * widget.fs : 70 * widget.fs;

    if (widget.project.thumbnailAsset != null && !_hasImageError) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.tvAccent.withOpacity(0.3), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(
            widget.project.thumbnailAsset!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && !_hasImageError) {
                  setState(() => _hasImageError = true);
                }
              });
              return _buildPlaceholder(size, colors);
            },
          ),
        ),
      );
    }

    return _buildPlaceholder(size, colors);
  }

  Widget _buildPlaceholder(double size, dynamic colors) {
    final isCompact = ScreenUtils.isCompactMobile(context);
    final firstLetter = widget.project.title.isNotEmpty ? widget.project.title[0].toUpperCase() : 'P';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.tvAccent.withOpacity(0.25),
            colors.tvAccent.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: colors.tvAccent.withOpacity(0.3), width: 1),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: isCompact ? 24 : 32,
            fontWeight: FontWeight.bold,
            color: colors.tvAccent.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fs = widget.fs;
    final isCompact = ScreenUtils.isCompactMobile(context);
    final project = widget.project;

    return GestureDetector(
      onTap: _toggle,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          margin: EdgeInsets.only(bottom: 8 * fs),
          padding: EdgeInsets.fromLTRB(11 * fs, 9 * fs, 8 * fs, 9 * fs),
          decoration: BoxDecoration(
            color: _hovered ? colors.tvAccent.withOpacity(0.04) : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: _hovered ? colors.tvAccent : colors.tvAccent.withOpacity(0.3),
                width: _hovered ? 1.5 : 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThumbnail(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              project.index,
                              style: AppFonts.tvChannel(
                                color: colors.tvAccent,
                                size: 7 * fs,
                                letterSpacing: 2,
                              ),
                            ),
                            if (project.category != null && !isCompact) ...[
                              SizedBox(width: 6 * fs),
                              Text(
                                project.category!.label,
                                style: AppFonts.tvChannel(
                                  color: colors.textSecondary,
                                  size: 7 * fs,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                            if (project.role != null && project.role!.isNotEmpty && !isCompact) ...[
                              SizedBox(width: 6 * fs),
                              Text(
                                project.role!,
                                style: AppFonts.tvChannel(
                                  color: colors.textSecondary,
                                  size: 7 * fs,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 4 * fs),
                        Text(
                          project.title,
                          style: AppFonts.tvRetro(
                            color: _hovered ? colors.textSecondary : colors.textPrimary,
                            size: isCompact ? 10 * fs : 12 * fs,
                          ),
                        ),
                        SizedBox(height: 3 * fs),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: Text(
                            project.techStack.join(' · '),
                            style: AppFonts.tvRetro(
                              color: colors.warmWhiteDim,
                              size: isCompact ? 6 * fs : 7 * fs,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        project.year,
                        style: AppFonts.tvRetro(
                          color: colors.textPrimary,
                          size: isCompact ? 6 * fs : 7 * fs,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(height: 4 * fs),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          '▾',
                          style: TextStyle(
                            fontSize: isCompact ? 8 * fs : 10 * fs,
                            color: _hovered ? colors.tvAccent.withOpacity(0.5) : const Color(0x30ffffff),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizeTransition(
                sizeFactor: _expandAnim,
                child: FadeTransition(
                  opacity: _expandAnim,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8 * fs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 1,
                          color: colors.tvAccent.withOpacity(0.08),
                          margin: EdgeInsets.only(bottom: 8 * fs),
                        ),
                        if (project.description.isNotEmpty)
                          Text(
                            project.description,
                            style: AppFonts.bodySmall(
                              color: colors.textSecondary,
                              size: isCompact ? 8 * fs : 9.5 * fs,
                              height: 1.5,
                            ),
                          ),
                        if (project.urlLink != null ||
                            project.playStoreUrl != null ||
                            project.thumbnailAsset != null ||
                            (project.screenshots != null && project.screenshots!.isNotEmpty)) ...[
                          SizedBox(height: 8 * fs),
                          GestureDetector(
                            onTap: _onViewProject,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8, top: 8, right: 16),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'VIEW PROJECT  ↗',
                                    style: AppFonts.tvRetro(
                                      color: colors.tvAccent,
                                      size: isCompact ? 7 * fs : 8 * fs,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}