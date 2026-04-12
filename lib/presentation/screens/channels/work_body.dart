import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/portfolio_repository.dart';

class WorkBody extends StatelessWidget {
  const WorkBody({super.key, required this.fs});
  final double fs;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isCompact = ScreenUtils.isCompactMobile(context);
    final workItems = PortfolioRepository.work;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(12 * fs, 20 * fs, 12 * fs, 14 * fs),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 16 * fs, top: 6 * fs),
            child: Column(
              children: [
                Text(
                  'WORK EXPERIENCE',
                  style: AppFonts.tvChannel(
                    color: colors.tvAccentLight,
                    size: isCompact ? 10 * fs : 12 * fs,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 1,
                  color: colors.tvAccent.withOpacity(0.3),
                ),
              ],
            ),
          ),

          for (int i = 0; i < workItems.length; i++)
            Container(
              margin: EdgeInsets.only(bottom: i == workItems.length - 1 ? 0 : 16 * fs),
              child: _WorkCard(
                project: workItems[i],
                fs: fs,
                isCompact: isCompact,
              ),
            ),
        ],
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({
    required this.project,
    required this.fs,
    required this.isCompact,
  });

  final ProjectModel project;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.all(isCompact ? 12 * fs : 16 * fs),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.surfaceAlt.withOpacity(0.3),
            colors.surfaceAlt.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _YearBadge(year: project.year, fs: fs, isCompact: isCompact),
              _RoleBadge(role: project.role ?? 'ROLE', fs: fs, isCompact: isCompact),
            ],
          ),

          SizedBox(height: 12 * fs),

          Text(
            project.title,
            style: AppFonts.heading(
              color: colors.textPrimary,
              size: isCompact ? 14 * fs : 16 * fs,
            ),
          ),

          SizedBox(height: 8 * fs),

          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: project.techStack.map((tech) => _TechChip(tech: tech, fs: fs, isCompact: isCompact)).toList(),
          ),

          SizedBox(height: 12 * fs),

          Text(
            project.description,
            style: AppFonts.bodySmall(
              color: colors.textSecondary,
              size: isCompact ? 9 * fs : 10 * fs,
              height: 1.5,
            ),
          ),

          if (project.playStoreUrl != null) ...[
            SizedBox(height: 12 * fs),
            _ProjectLink(url: project.playStoreUrl!, fs: fs, isCompact: isCompact),
          ],
        ],
      ),
    );
  }
}

class _YearBadge extends StatelessWidget {
  const _YearBadge({required this.year, required this.fs, required this.isCompact});
  final String year;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fs, vertical: 4 * fs),
      decoration: BoxDecoration(
        color: colors.tvAccent.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        year,
        style: AppFonts.tvRetro(
          color: colors.textSecondary,
          size: isCompact ? 8 * fs : 9 * fs,
        ),
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role, required this.fs, required this.isCompact});
  final String role;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fs, vertical: 4 * fs),
      decoration: BoxDecoration(
        color: colors.tvPowerOn.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        role,
        style: AppFonts.tvRetro(
          color: colors.tvPowerOn,
          size: isCompact ? 8 * fs : 9 * fs,
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.tech, required this.fs, required this.isCompact});
  final String tech;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * fs, vertical: 3 * fs),
      decoration: BoxDecoration(
        color: colors.border.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        tech,
        style: AppFonts.tvRetro(
          color: colors.textMuted,
          size: isCompact ? 7 * fs : 8 * fs,
        ),
      ),
    );
  }
}

class _ProjectLink extends StatelessWidget {
  const _ProjectLink({required this.url, required this.fs, required this.isCompact});
  final String url;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Row(
        children: [
          Icon(Icons.link, size: 12, color: colors.tvAccentLight),
          const SizedBox(width: 4),
          Text(
            'view project',
            style: AppFonts.tvChannel(
              color: colors.tvAccentLight,
              size: isCompact ? 8 * fs : 9 * fs,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}