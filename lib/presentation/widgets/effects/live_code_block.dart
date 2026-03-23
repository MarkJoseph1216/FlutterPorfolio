import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/providers/scroll_controller_provider.dart';
import '../../../data/repositories/portfolio_repository.dart';

class LiveCodeBlock extends StatefulWidget {
  const LiveCodeBlock({super.key});

  @override
  State<LiveCodeBlock> createState() => _LiveCodeBlockState();
}

class _LiveCodeBlockState extends State<LiveCodeBlock> {
  static final _lines = <List<(String, String)>>[
    [('// about me', 'comment')],
    [
      ('final ', 'keyword'),
      ('developer', 'variable'),
      (' = ', 'plain'),
      ('Developer(', 'type')
    ],
    [
      ('  name', 'variable'),
      (': ', 'plain'),
      ("'${PortfolioRepository.name}'", 'string'),
      (',', 'punctuation')
    ],
    [
      ('  role', 'variable'),
      (': ', 'plain'),
      ("'${PortfolioRepository.role}'", 'string'),
      (',', 'punctuation')
    ],
    [
      ('  location', 'variable'),
      (': ', 'plain'),
      ("'${PortfolioRepository.location}'", 'string'),
      (',', 'punctuation')
    ],
    [
      ('  experience', 'variable'),
      (': ', 'plain'),
      ("'${PortfolioRepository.experience}'", 'string'),
      (',', 'punctuation')
    ],
    [
      ('  apps', 'variable'),
      (': ', 'plain'),
      ('12', 'number'),
      (',', 'punctuation')
    ],
    [
      ('  downloads', 'variable'),
      (': ', 'plain'),
      ("'50K+'", 'string'),
      (',', 'punctuation')
    ],
    [
      ('  available', 'variable'),
      (': ', 'plain'),
      ('true', 'keyword'),
      (',', 'punctuation')
    ],
    [(')', 'type'), (';', 'punctuation')],
  ];

  static const _charDelay = Duration(milliseconds: 18);
  static const _lineDelay = Duration(milliseconds: 60);

  late List<int> _visibleChars;

  bool _triggered = false;
  ScrollController? _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _visibleChars = List.filled(_lines.length, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCtrl = ScrollControllerProvider.of(context);
      _scrollCtrl?.addListener(_check);
      _check();
    });
  }

  @override
  void dispose() {
    _scrollCtrl?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_triggered || !mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;
    final screenH = MediaQuery.sizeOf(context).height;
    if (box.localToGlobal(Offset.zero).dy < screenH * 0.92) {
      _triggered = true;
      _scrollCtrl?.removeListener(_check);
      _scrollCtrl = null;
      _startTyping();
    }
  }

  Future<void> _startTyping() async {
    for (var lineIdx = 0; lineIdx < _lines.length; lineIdx++) {
      await Future.delayed(_lineDelay);

      final fullLine = _lines[lineIdx].map((e) => e.$1).join();
      for (var charIdx = 1; charIdx <= fullLine.length; charIdx++) {
        if (!mounted) return;
        setState(() => _visibleChars[lineIdx] = charIdx);
        await Future.delayed(_charDelay);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surfaceAlt,
        border: Border.all(color: c.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WindowChrome(),
          const SizedBox(height: 4),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _lines.asMap().entries.map((entry) {
                final lineIdx = entry.key;
                final tokens = entry.value;
                return _CodeLine(
                  tokens: tokens,
                  lineNumber: lineIdx + 1,
                  visibleChars: _visibleChars[lineIdx],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.forward()).fadeIn(duration: 400.ms);
  }
}

class _WindowChrome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          const _TrafficDot(color: Color(0xFFFF5F57)),
          const SizedBox(width: 6),
          const _TrafficDot(color: Color(0xFFFFBD2E)),
          const SizedBox(width: 6),
          const _TrafficDot(color: Color(0xFF28C840)),
          const SizedBox(width: 16),
          Text(
            'about.dart',
            style: AppFonts.mono(size: 11, color: c.textMuted),
          ),
        ],
      ),
    );
  }
}

class _TrafficDot extends StatelessWidget {
  const _TrafficDot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.85),
      ),
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine({
    required this.tokens,
    required this.lineNumber,
    required this.visibleChars,
  });

  final List<(String, String)> tokens;
  final int lineNumber;
  final int visibleChars;

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    final spans = <TextSpan>[];
    var remaining = visibleChars;

    for (final (text, role) in tokens) {
      if (remaining <= 0) break;
      final visible = text.substring(0, remaining.clamp(0, text.length));
      spans.add(TextSpan(
        text: visible,
        style: _styleForRole(role, c),
      ));
      remaining -= text.length;
    }

    final fullLen = tokens.map((t) => t.$1.length).fold(0, (a, b) => a + b);
    final isTyping = visibleChars > 0 && visibleChars < fullLen;
    final isDone = visibleChars == fullLen;

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$lineNumber',
              style: AppFonts.mono(size: 12, color: c.textGhost),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  ...spans,
                  if (isTyping || (isDone && lineNumber == _lastActiveLine()))
                    const WidgetSpan(child: _Cursor()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _lastActiveLine() {
    return tokens.isNotEmpty ? lineNumber : 0;
  }

  TextStyle _styleForRole(String role, dynamic c) {
    switch (role) {
      case 'keyword':
        return AppFonts.mono(size: 13, color: const Color(0xFFCF8EF4));
      case 'type':
        return AppFonts.mono(size: 13, color: const Color(0xFF7ECFFF));
      case 'variable':
        return AppFonts.mono(size: 13, color: const Color(0xFFF9CF89));
      case 'string':
        return AppFonts.mono(size: 13, color: const Color(0xFF98C379));
      case 'number':
        return AppFonts.mono(size: 13, color: const Color(0xFFD19A66));
      case 'comment':
        return AppFonts.mono(
          size: 13,
          color: c.textMuted,
        ).copyWith(fontStyle: FontStyle.italic);
      case 'punctuation':
        return AppFonts.mono(size: 13, color: c.textMuted);
      default:
        return AppFonts.mono(size: 13, color: c.textSecondary);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Blinking cursor
// ─────────────────────────────────────────────────────────────────────────────

class _Cursor extends StatefulWidget {
  const _Cursor();

  @override
  State<_Cursor> createState() => _CursorState();
}

class _CursorState extends State<_Cursor> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _ctrl.value > 0.5 ? 1.0 : 0.0,
        child: Container(
          width: 2,
          height: 14,
          color: c.warmWhite,
          margin: const EdgeInsets.only(left: 1),
        ),
      ),
    );
  }
}
