import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/utils/screen_utils.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../../core/services/email_service.dart';
import '../../widgets/common/screen_text_field.dart';

class ContactBody extends StatefulWidget {
  const ContactBody({super.key, required this.fs});
  final double fs;

  @override
  State<ContactBody> createState() => _ContactBodyState();
}

class _ContactBodyState extends State<ContactBody> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final ScrollController _scroll;
  static const double _contentHeight = 500;
  int _tab = 0;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _msgCtrl = TextEditingController();

  bool _isSending = false;
  String? _errorMessage;
  bool _showSuccess = false;
  String _successMessage = '';
  String _currentMethod = '';

  @override
  void initState() {
    super.initState();
    _scroll = ScrollController();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 24))
      ..addListener(_onTick)
      ..repeat();
  }

  void _onTick() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max > 0) {
      _scroll.jumpTo((_ctrl.value * (max + _contentHeight)).clamp(0, max));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  bool _validateForm() {
    if (_nameCtrl.text.trim().isEmpty) {
      _showError('Please enter your name');
      return false;
    }
    if (_emailCtrl.text.trim().isEmpty) {
      _showError('Please enter your email');
      return false;
    }
    if (!_isValidEmail(_emailCtrl.text.trim())) {
      _showError('Please enter a valid email address');
      return false;
    }
    if (_msgCtrl.text.trim().isEmpty) {
      _showError('Please enter your message');
      return false;
    }
    return true;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _showSuccess = false;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _errorMessage == message) {
        setState(() => _errorMessage = null);
      }
    });
  }

  void _showSuccessMessage(String message, String method) {
    setState(() {
      _showSuccess = true;
      _successMessage = message;
      _isSending = false;
      _currentMethod = method;
    });

    _nameCtrl.clear();
    _emailCtrl.clear();
    _msgCtrl.clear();
  }

  Future<void> _submitForm() async {
    if (!_validateForm()) return;

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final message = _msgCtrl.text.trim();

    final result = await EmailService.sendEmailWithFallback(
      name: name,
      email: email,
      message: message,
      onStatus: (status, method) {
        print('Status: $status - Method: $method');
      },
    );

    if (result.success) {
      _showSuccessMessage(result.message, result.method);
    } else {
      setState(() {
        _errorMessage = result.message;
        _isSending = false;
      });
    }
  }

  Widget _section(String label, List<Widget> children) {
    final colors = AppColors.of(context);
    return Column(children: [
      Text(label, style: AppFonts.tvChannel(color: colors.tvAccent.withOpacity(0.7), size: 7, letterSpacing: 4)),
      const SizedBox(height: 5),
      ...children,
      const SizedBox(height: 22),
    ]);
  }

  Widget _cname(String t, {double size = 15, Color? color}) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(t, style: AppFonts.heading(color: color ?? colors.textPrimary, size: size, letterSpacing: 1.5)),
    );
  }

  Widget _csub(String t, {Color? color}) {
    final colors = AppColors.of(context);
    return Text(t, style: AppFonts.tvChannel(color: color ?? colors.textMuted, size: 7, letterSpacing: 2));
  }

  Widget _divider() {
    final colors = AppColors.of(context);
    return Container(width: 18, height: 1, margin: const EdgeInsets.symmetric(vertical: 12), color: colors.tvAccent.withOpacity(0.25));
  }

  Widget _creditsScroll() {
    final fs = widget.fs;
    final isCompact = ScreenUtils.isCompactMobile(context);
    final colors = AppColors.of(context);

    final credits = <Widget>[
      SizedBox(height: isCompact ? 40 * fs : 80 * fs),
      Text('— 한국 드라마 비전 포트폴리오 —', style: AppFonts.tvChannel(color: const Color(0x1Affffff), size: isCompact ? 5 * fs : 7 * fs, letterSpacing: 4)),
      SizedBox(height: isCompact ? 12 * fs : 20 * fs),
      _section('주연 · STARRING', [
        _cname(PortfolioRepository.name, size: isCompact ? 14 * fs : 18 * fs, color: colors.textPrimary),
        SizedBox(height: 2 * fs),
        _csub(PortfolioRepository.nameKr),
      ]),
      _divider(),
      _section('역할 · AS', [
        _cname(PortfolioRepository.role, size: isCompact ? 10 * fs : 12 * fs),
      ]),
      _divider(),
      _section('제작 · BUILT WITH', [
        _cname('Flutter · Dart', size: isCompact ? 9 * fs : 11 * fs),
        _csub('Flutter Animate · BLoC · EmailJS'),
      ]),
      _divider(),
      _section('위치 · BASED IN', [
        _cname(PortfolioRepository.location, size: isCompact ? 10 * fs : 12 * fs),
      ]),
      _divider(),
      _section('경험 · EXPERIENCE', [
        _cname(PortfolioRepository.experience, size: isCompact ? 10 * fs : 12 * fs),
      ]),
      _divider(),
      _section('상태 · STATUS', [
        _cname('Open to Work', size: isCompact ? 10 * fs : 12 * fs, color: colors.tvPowerOn),
        _csub('기회를 찾고 있습니다', color: colors.tvAccent.withOpacity(0.73)),
      ]),
      SizedBox(height: isCompact ? 12 * fs : 16 * fs),
      Text('— END —', style: AppFonts.tvChannel(color: colors.warmWhiteDim.withOpacity(0.73), size: isCompact ? 7 * fs : 9 * fs, letterSpacing: 6)),
      SizedBox(height: isCompact ? 60 * fs : 100 * fs),
    ];

    return SingleChildScrollView(
      controller: _scroll,
      physics: const NeverScrollableScrollPhysics(),
      child: Center(child: Column(children: credits)),
    );
  }

  Widget _linksTab() {
    final fs = widget.fs;
    final isCompact = ScreenUtils.isCompactMobile(context);
    final colors = AppColors.of(context);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 * fs : 20 * fs, vertical: 8 * fs),
      child: Column(
        children: [
          ...PortfolioRepository.contactLinks.asMap().entries.map((entry) {
            final index = entry.key;
            final l = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: index == PortfolioRepository.contactLinks.length - 1 ? 0 : 12 * fs),
              decoration: BoxDecoration(
                color: colors.surfaceAlt.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4 * fs),
                child: _LinkRow(label: l.label, value: l.value, url: l.url, fs: fs),
              ),
            );
          }),
          SizedBox(height: isCompact ? 20 * fs : 10 * fs),
        ],
      ),
    );
  }

  Widget _messageTab() {
    final fs = widget.fs;
    final isCompact = ScreenUtils.isCompactMobile(context);
    final colors = AppColors.of(context);

    if (_showSuccess) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16 * fs, vertical: 20 * fs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isCompact ? 8 * fs : 12 * fs),
                decoration: BoxDecoration(
                  color: colors.tvPowerOn.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: isCompact ? 32 * fs : 40 * fs,
                  color: colors.tvPowerOn,
                ),
              ),
              SizedBox(height: isCompact ? 12 * fs : 16 * fs),

              Text(
                _currentMethod == 'Email Client' ? 'Email App Opened' : 'Message Sent!',
                style: AppFonts.heading(
                  color: colors.textPrimary,
                  size: isCompact ? 18 * fs : 22 * fs,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isCompact ? 8 * fs : 12 * fs),

              Text(
                _successMessage,
                style: AppFonts.bodySmall(
                  color: colors.textSecondary,
                  size: isCompact ? 11 * fs : 12 * fs,
                ),
                textAlign: TextAlign.center,
              ),

              if (_currentMethod == 'Email Client') ...[
                SizedBox(height: isCompact ? 10 * fs : 12 * fs),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * fs, vertical: 6 * fs),
                  decoration: BoxDecoration(
                    color: colors.surfaceAlt.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '📧 Check your email app and send',
                    style: AppFonts.tvChannel(
                      color: colors.textMuted,
                      size: isCompact ? 8 * fs : 9 * fs,
                      letterSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              SizedBox(height: isCompact ? 16 * fs : 20 * fs),

              GestureDetector(
                onTap: () => setState(() {
                  _showSuccess = false;
                  _errorMessage = null;
                  _currentMethod = '';
                  _successMessage = '';
                }),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isCompact ? 10 * fs : 12 * fs),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.tvAccent, colors.tvAccent.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: colors.tvAccent.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: isCompact ? 14 * fs : 16 * fs,
                        color: Colors.white,
                      ),
                      SizedBox(width: 6 * fs),
                      Text(
                        'SEND ANOTHER',
                        style: AppFonts.tvRetro(
                          color: Colors.white,
                          size: isCompact ? 8 * fs : 9 * fs,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: isCompact ? 8 * fs : 12 * fs),

              GestureDetector(
                onTap: () => setState(() {
                  _showSuccess = false;
                  _errorMessage = null;
                  _currentMethod = '';
                  _successMessage = '';
                }),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: isCompact ? 8 * fs : 10 * fs),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      'CLOSE',
                      style: AppFonts.tvChannel(
                        color: colors.textMuted,
                        size: isCompact ? 8 * fs : 9 * fs,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(14 * fs, 6 * fs, 14 * fs, 6 * fs),
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_errorMessage != null)
            Container(
              margin: EdgeInsets.only(bottom: 12 * fs),
              padding: EdgeInsets.all(8 * fs),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, size: 14, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10 * fs,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ScreenTextField(label: 'NAME:', ctrl: _nameCtrl, hint: 'Your name', fs: fs),
          SizedBox(height: 12 * fs),
          ScreenTextField(label: 'EMAIL:', ctrl: _emailCtrl, hint: 'email@gmail.com', fs: fs),
          SizedBox(height: 12 * fs),
          ScreenTextField(label: 'MESSAGE:', ctrl: _msgCtrl, hint: 'Tell me about your project...', maxLines: 3, fs: fs),
          SizedBox(height: 16 * fs),

          GestureDetector(
            onTap: _isSending ? null : _submitForm,
            child: Opacity(
              opacity: _isSending ? 0.6 : 1.0,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 12 * fs),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.tvAccent, colors.tvAccent.withOpacity(0.7)],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: colors.tvAccent.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSending
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 16 * fs,
                        height: 16 * fs,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'SENDING...',
                        style: AppFonts.tvRetro(
                          color: Colors.white,
                          size: 11 * fs,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  )
                      : Text(
                    'SEND MESSAGE  →',
                    style: AppFonts.tvRetro(
                      color: Colors.white,
                      size: 8 * fs,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 12 * fs),

          GestureDetector(
            onTap: () {
              setState(() {
                _nameCtrl.clear();
                _emailCtrl.clear();
                _msgCtrl.clear();
                _errorMessage = null;
              });
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10 * fs),
              decoration: BoxDecoration(
                border: Border.all(color: colors.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  'CLEAR FORM',
                  style: AppFonts.tvChannel(
                    color: colors.textMuted,
                    size: 8 * fs,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 16 * fs),

          Center(
            child: Column(
              children: [
                Text(
                  'or email me directly at',
                  style: AppFonts.tvChannel(color: colors.textMuted, size: 8 * fs, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () async {
                    final emailUri = Uri(scheme: 'mailto', path: PortfolioRepository.email);
                    if (await canLaunchUrl(emailUri)) {
                      await launchUrl(emailUri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Text(
                    PortfolioRepository.email,
                    style: AppFonts.tvRetro(
                      color: colors.tvAccentLight,
                      size: 10 * fs,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isCompact ? 20 * fs : 30 * fs),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fs = widget.fs;

    return Column(children: [
      Expanded(flex: 58, child: _creditsScroll()),
      Container(height: 1, color: const Color(0x158b0000)),
      _TabBar(selectedIndex: _tab, onTap: (i) => setState(() => _tab = i), fs: fs),
      Container(height: 1, color: const Color(0x0Affffff)),
      Expanded(flex: 42, child: _tab == 0 ? _linksTab() : _messageTab()),
    ]);
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selectedIndex, required this.onTap, required this.fs});
  final int selectedIndex;
  final void Function(int) onTap;
  final double fs;

  @override
  Widget build(BuildContext context) {
    final isCompact = ScreenUtils.isCompactMobile(context);
    return Row(
      children: [
        Expanded(child: _Tab(label: 'LINKS', active: selectedIndex == 0, onTap: () => onTap(0), fs: fs, isCompact: isCompact)),
        Container(width: 1, height: isCompact ? 24 : 28, color: const Color(0x12ffffff)),
        Expanded(child: _Tab(label: 'MESSAGE', active: selectedIndex == 1, onTap: () => onTap(1), fs: fs, isCompact: isCompact)),
      ],
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap, required this.fs, required this.isCompact});
  final String label;
  final bool active;
  final VoidCallback onTap;
  final double fs;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 * fs : 16 * fs, vertical: isCompact ? 5 * fs : 7 * fs),
        decoration: BoxDecoration(
          color: active ? colors.tvAccent.withOpacity(0.05) : Colors.transparent,
          border: Border(bottom: BorderSide(color: active ? colors.tvAccent : Colors.transparent, width: 1.5)),
        ),
        child: Text(label, style: AppFonts.tvChannel(color: active ? colors.tvAccentLight : colors.textMuted, size: isCompact ? 7 * fs : 8 * fs, letterSpacing: 2)),
      ),
    );
  }
}

class _LinkRow extends StatefulWidget {
  const _LinkRow({required this.label, required this.value, required this.url, required this.fs});
  final String label, value, url;
  final double fs;

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _hov = false;

  Future<void> _open() async {
    final uri = Uri.parse(widget.url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fs = widget.fs;
    final isCompact = ScreenUtils.isCompactMobile(context);
    final colors = AppColors.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit: (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(vertical: isCompact ? 8 * fs : 10 * fs),
          color: _hov ? colors.tvAccent.withOpacity(0.03) : Colors.transparent,
          child: Row(children: [
            SizedBox(width: isCompact ? 60 * fs : 72 * fs, child: Text(widget.label, style: AppFonts.tvChannel(color: colors.textMuted, size: isCompact ? 6.5 * fs : 7.5 * fs, letterSpacing: 1))),
            Expanded(child: Text(widget.value, style: AppFonts.bodySmall(color: _hov ? colors.textPrimary : colors.textSecondary, size: isCompact ? 8 * fs : 10 * fs))),
            AnimatedOpacity(opacity: _hov ? 1.0 : 0.3, duration: const Duration(milliseconds: 140), child: Text('↗', style: TextStyle(fontSize: isCompact ? 8 * fs : 10 * fs, color: colors.textMuted))),
          ]),
        ),
      ),
    );
  }
}