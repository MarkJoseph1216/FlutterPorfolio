import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';

class ProjectRow extends StatefulWidget {
  const ProjectRow({
    super.key,
    required this.number,
    required this.title,
    required this.tech,
    required this.year,
    required this.fs,
    this.role,
    this.description,
    this.category,
    this.url,
    this.thumbnailAsset,
  });

  final String number, title, tech, year;
  final double fs;
  final String? role, description, category, url, thumbnailAsset;

  @override
  State<ProjectRow> createState() => _ProjectRowState();
}

class _ProjectRowState extends State<ProjectRow> with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _expanded = false;
  late final AnimationController _expandCtrl;
  late final Animation<double> _expandAnim;

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

  Future<void> _launch() async {
    if (widget.url == null) return;
    final uri = Uri.parse(widget.url!);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fs = widget.fs;
    final isCompact = ScreenUtils.isCompactMobile(context);

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
            border: Border(left: BorderSide(color: _hovered ? colors.tvAccent : colors.tvAccent.withOpacity(0.3), width: _hovered ? 1.5 : 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail image if available
                  if (widget.thumbnailAsset != null) ...[
                    Container(
                      width: isCompact ? 50 * fs : 70 * fs,
                      height: isCompact ? 50 * fs : 70 * fs,
                      margin: EdgeInsets.only(right: 12 * fs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: colors.tvAccent.withOpacity(0.3), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.asset(
                          widget.thumbnailAsset!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colors.surfaceAlt,
                            child: Icon(Icons.image_not_supported, size: 20, color: colors.textMuted),
                          ),
                        ),
                      ),
                    ),
                  ],

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Text(widget.number, style: AppFonts.tvChannel(color: colors.tvAccent.withOpacity(0.38), size: 7 * fs, letterSpacing: 2)),
                          if (widget.category != null && !isCompact) ...[
                            SizedBox(width: 6 * fs),
                            Text(widget.category!.toUpperCase(), style: AppFonts.tvChannel(color: const Color(0x38ffffff), size: 7 * fs, letterSpacing: 1)),
                          ],
                          if (widget.role != null && widget.role!.isNotEmpty && !isCompact) ...[
                            SizedBox(width: 6 * fs),
                            Text(widget.role!, style: AppFonts.tvChannel(color: const Color(0x38ffffff), size: 7 * fs, letterSpacing: 1)),
                          ],
                        ]),
                        SizedBox(height: 4 * fs),
                        Text(widget.title, style: AppFonts.subheading(color: _hovered ? colors.textPrimary : colors.textSecondary, size: isCompact ? 10 * fs : 12 * fs)),
                        SizedBox(height: 3 * fs),
                        Text(widget.tech, style: AppFonts.tvRetro(color: const Color(0x40ffffff), size: isCompact ? 6 * fs : 7 * fs, letterSpacing: 1)),
                      ],
                    ),
                  ),

                  // Year and expand icon
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(widget.year, style: AppFonts.tvRetro(color: const Color(0x2Effffff), size: isCompact ? 6 * fs : 7 * fs, letterSpacing: 1)),
                      SizedBox(height: 4 * fs),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: Text('▾', style: TextStyle(fontSize: isCompact ? 8 * fs : 10 * fs, color: _hovered ? colors.tvAccent.withOpacity(0.5) : const Color(0x30ffffff))),
                      ),
                    ],
                  ),
                ],
              ),

              // Expandable description
              SizeTransition(
                sizeFactor: _expandAnim,
                child: FadeTransition(
                  opacity: _expandAnim,
                  child: Padding(
                    padding: EdgeInsets.only(top: 8 * fs),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 1, color: colors.tvAccent.withOpacity(0.08), margin: EdgeInsets.only(bottom: 8 * fs)),
                        if (widget.description != null)
                          Text(widget.description!, style: AppFonts.bodySmall(color: const Color(0x55ffffff), size: isCompact ? 8 * fs : 9.5 * fs, height: 1.5)),
                        if (widget.url != null) ...[
                          SizedBox(height: 8 * fs),
                          GestureDetector(
                            onTap: _launch,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('VIEW PROJECT  ↗', style: AppFonts.tvRetro(color: colors.tvAccent.withOpacity(0.5), size: isCompact ? 7 * fs : 8 * fs, letterSpacing: 2)),
                              ],
                            ),
                          ),
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