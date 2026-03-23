import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../common/section_meta.dart';
import '../common/section_wrapper.dart';
import '../effects/ink_divider.dart';

class ContactSection extends StatelessWidget {
  const ContactSection({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return SectionWrapper(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SectionMeta(index: '04', label: 'Contact'),
        const SizedBox(height: 56),
        Text("Got an idea?\nLet’s talk.",
            style: AppFonts.heading(size: 38, color: c.textPrimary, letterSpacing: -1.5, weight: FontWeight.w700))
            .animate().fadeIn(duration: 700.ms).slideY(begin: 0.08, end: 0),
        const SizedBox(height: 20),
        Text('New projects, new challenges, new conversations.',
            style: AppFonts.body(size: 14, color: c.textSecondary))
            .animate().fadeIn(delay: 200.ms, duration: 600.ms),
        const SizedBox(height: 48),
        const InkDivider(opacity: 0.22),
        const SizedBox(height: 40),
        ...PortfolioRepository.contactLinks.map((l) => _LinkRow(label: l.label, value: l.value, url: l.url)),
        const SizedBox(height: 56),
        const InkDivider(opacity: 0.22),
        const SizedBox(height: 48),
        const _ContactForm(),
      ]),
    );
  }
}

class _LinkRow extends StatefulWidget {
  const _LinkRow({required this.label, required this.value, required this.url});
  final String label, value, url;
  @override State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _hov = false;
  Future<void> _open() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          color: _hov ? c.warmWhiteGlow : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Row(children: [
            SizedBox(width: 100,
                child: Text(widget.label, style: AppFonts.label(size: 14, color: c.textMuted, letterSpacing: 0.14))),
            Expanded(child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: AppFonts.body(size: 13, color: _hov ? c.textPrimary : c.textSecondary, height: 1),
              child: Text(widget.value),
            )),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 160),
              style: AppFonts.mono(size: 12, color: _hov ? c.textPrimary : c.textGhost),
              child: const Text('↗'),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ContactForm extends StatefulWidget {
  const _ContactForm();
  @override State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();
  bool _sent = false;

  @override
  void dispose() { _nameCtrl.dispose(); _emailCtrl.dispose(); _msgCtrl.dispose(); super.dispose(); }

  void _submit() {
    if (_nameCtrl.text.isNotEmpty && _emailCtrl.text.isNotEmpty && _msgCtrl.text.isNotEmpty) {
      setState(() => _sent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    if (_sent) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Sent.', style: AppFonts.heading(size: 28, color: c.textPrimary, letterSpacing: -1)),
        const SizedBox(height: 12),
        Text("I'll be in touch shortly.", style: AppFonts.body(size: 14, color: c.textSecondary)),
      ]).animate().fadeIn(duration: 400.ms);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Send a message', style: AppFonts.label(size: 14, color: c.textMuted, letterSpacing: 0.18)),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: _FormField(label: 'Name',  ctrl: _nameCtrl,  hint: 'Your name')),
        const SizedBox(width: 16),
        Expanded(child: _FormField(label: 'Email', ctrl: _emailCtrl, hint: 'email@gmail.com')),
      ]),
      const SizedBox(height: 16),
      _FormField(label: 'Message', ctrl: _msgCtrl, hint: 'Tell me about your project...', maxLines: 5),
      const SizedBox(height: 24),
      _SubmitButton(onTap: _submit),
    ]).animate().fadeIn(delay: 300.ms, duration: 600.ms);
  }
}

class _FormField extends StatefulWidget {
  const _FormField({required this.label, required this.ctrl, required this.hint, this.maxLines = 1});
  final String label, hint; final TextEditingController ctrl; final int maxLines;
  @override State<_FormField> createState() => _FormFieldState();
}

class _FormFieldState extends State<_FormField> with SingleTickerProviderStateMixin {
  late final AnimationController _cursorCtrl;
  late final Animation<double> _cursorFade;
  late final FocusNode _focus;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(() => setState(() => _focused = _focus.hasFocus));
    _cursorCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _cursorFade = CurvedAnimation(parent: _cursorCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _focus.dispose(); _cursorCtrl.dispose(); super.dispose(); }

  OutlineInputBorder _border(Color color) =>
      OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: color));

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: AppFonts.label(size: 15, color: _focused ? c.textPrimary : c.textMuted, letterSpacing: 0.14),
        child: Text(widget.label),
      ),
      const SizedBox(height: 8),
      Stack(children: [
        TextField(
          controller: widget.ctrl, focusNode: _focus, maxLines: widget.maxLines,
          style: AppFonts.body(size: 14, color: c.textPrimary, height: 1.6),
          cursorColor: c.warmWhite, cursorWidth: 1.5,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppFonts.body(size: 14, color: c.textGhost, height: 1.6),
            filled: true,
            fillColor: _focused ? c.surface : c.background,
            contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            border: _border(c.border),
            enabledBorder: _border(c.border),
            focusedBorder: _border(c.warmWhiteFaint),
          ),
        ),
        if (_focused)
          Positioned(left: 0, top: 0, bottom: 0,
              child: FadeTransition(
                opacity: _cursorFade,
                child: Container(width: 2, color: c.warmWhite),
              )),
      ]),
    ]);
  }
}

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.onTap});
  final VoidCallback onTap;
  @override State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
          color: _hov ? c.warmWhiteDim : c.warmWhite,
          child: Text('Send message',
              style: AppFonts.label(size: 11, weight: FontWeight.w600, color: c.background, letterSpacing: 0.08)),
        ),
      ),
    );
  }
}