import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../data/repositories/portfolio_repository.dart';

class LiveCodeBlock extends StatefulWidget {
  const LiveCodeBlock({super.key, required this.fs, required this.isCompact});
  final double fs;
  final bool isCompact;

  @override
  State<LiveCodeBlock> createState() => _LiveCodeBlockState();
}

class _LiveCodeBlockState extends State<LiveCodeBlock> {
  static final _lines = <List<(String, String)>>[
    [('// about me', 'comment')],
    [('final ', 'keyword'), ('developer', 'variable'), (' = ', 'plain'), ('Developer(', 'type')],
    [('  name', 'variable'), (': ', 'plain'), ("'${PortfolioRepository.name}'", 'string'), (',', 'punct')],
    [('  role', 'variable'), (': ', 'plain'), ("'${PortfolioRepository.role}'", 'string'), (',', 'punct')],
    [('  location', 'variable'), (': ', 'plain'), ("'${PortfolioRepository.location}'", 'string'), (',', 'punct')],
    [('  experience', 'variable'), (': ', 'plain'), ("'${PortfolioRepository.experience}'", 'string'), (',', 'punct')],
    [('  available', 'variable'), (': ', 'plain'), ('true', 'keyword'), (',', 'punct')],
    [('  since', 'variable'), (': ', 'plain'), ("'${PortfolioRepository.since}'", 'string'), (',', 'punct')],
    [(')', 'type'), (';', 'punct')],
  ];

  final List<int> _visibleChars = [];
  bool _started = false;
  late final List<int> _lineLengths;

  @override
  void initState() {
    super.initState();
    _lineLengths = _lines.map((tokens) => tokens.fold(0, (sum, t) => sum + t.$1.length)).toList();
    _visibleChars.addAll(List.filled(_lines.length, 0));
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTyping());
  }

  Future<void> _startTyping() async {
    if (!mounted || _started) return;
    _started = true;
    for (int lineIdx = 0; lineIdx < _lines.length; lineIdx++) {
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 80));
      for (int charIdx = 1; charIdx <= _lineLengths[lineIdx]; charIdx++) {
        if (!mounted) return;
        setState(() => _visibleChars[lineIdx] = charIdx);
        await Future.delayed(const Duration(milliseconds: 12));
      }
    }
  }

  @override
  void dispose() {
    _visibleChars.clear();
    super.dispose();
  }

  Color _getTokenColor(String role, BuildContext context) {
    final colors = ThemeProvider.isDark(context) ? AppColors.dark : AppColors.light;
    switch (role) {
      case 'keyword': return colors.syntaxKeyword;
      case 'type': return colors.syntaxType;
      case 'variable': return colors.syntaxVariable;
      case 'string': return colors.syntaxString;
      case 'number': return colors.syntaxNumber;
      case 'comment': return colors.syntaxComment;
      case 'punct': return colors.syntaxPunct;
      default: return colors.syntaxPlain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = widget.fs;
    final isCompact = widget.isCompact;
    final colors = AppColors.of(context);

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceAlt.withOpacity(0.5),
          border: Border.all(color: colors.border),
          borderRadius: BorderRadius.circular(isCompact ? 6 : 3),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 8 * fs : 10 * fs, vertical: isCompact ? 5 * fs : 7 * fs),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: colors.border))),
            child: Row(children: [
              _TrafficDot(color: const Color(0xFFFF5F57), fs: fs, isCompact: isCompact),
              SizedBox(width: isCompact ? 3 * fs : 5 * fs),
              _TrafficDot(color: const Color(0xFFFFBD2E), fs: fs, isCompact: isCompact),
              SizedBox(width: isCompact ? 3 * fs : 5 * fs),
              _TrafficDot(color: const Color(0xFF28C840), fs: fs, isCompact: isCompact),
              SizedBox(width: isCompact ? 8 * fs : 12 * fs),
              Flexible(child: Text('about.dart', overflow: TextOverflow.ellipsis, style: AppFonts.code(color: colors.textSecondary, size: isCompact ? 7 * fs : 8 * fs))),
            ]),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: isCompact ? const BouncingScrollPhysics() : const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(isCompact ? 8 * fs : 10 * fs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _lines.asMap().entries.map((e) {
                  final lineIdx = e.key;
                  final tokens = e.value;
                  int remaining = _visibleChars[lineIdx];
                  final spans = <InlineSpan>[];
                  bool isTyping = remaining > 0 && remaining < _lineLengths[lineIdx];

                  for (final (text, role) in tokens) {
                    if (remaining <= 0) break;
                    final vis = text.substring(0, remaining.clamp(0, text.length));
                    spans.add(TextSpan(
                        text: vis,
                        style: AppFonts.code(
                            color: _getTokenColor(role, context),
                            size: isCompact ? 8 * fs : 9 * fs
                        )
                    ));
                    remaining -= text.length;
                  }
                  if (isTyping) spans.add(WidgetSpan(child: _CursorBlink(fs: fs, isCompact: isCompact)));

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: isCompact ? 18 * fs : 22 * fs, child: Text('${lineIdx + 1}', style: AppFonts.code(color: colors.textMuted, size: isCompact ? 7 * fs : 8 * fs))),
                      SizedBox(width: isCompact ? 4 * fs : 8 * fs),
                      Expanded(child: RichText(text: TextSpan(children: spans), maxLines: 1, softWrap: false)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _TrafficDot extends StatelessWidget {
  const _TrafficDot({required this.color, required this.fs, required this.isCompact});
  final Color color;
  final double fs;
  final bool isCompact;
  @override
  Widget build(BuildContext context) => Container(width: isCompact ? 7 * fs : 9 * fs, height: isCompact ? 7 * fs : 9 * fs, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.8)));
}

class _CursorBlink extends StatefulWidget {
  const _CursorBlink({required this.fs, required this.isCompact});
  final double fs;
  final bool isCompact;
  @override
  State<_CursorBlink> createState() => _CursorBlinkState();
}

class _CursorBlinkState extends State<_CursorBlink> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 530));
    WidgetsBinding.instance.addPostFrameCallback((_) => _ctrl.repeat(reverse: true));
  }
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value > 0.5 ? 1.0 : 0.0,
        child: Container(
            width: 1.5 * widget.fs,
            height: widget.isCompact ? 8 * widget.fs : 10 * widget.fs,
            color: colors.textSecondary,
            margin: const EdgeInsets.only(left: 1)
        ),
      ),
    );
  }
}