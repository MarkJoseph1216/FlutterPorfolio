import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class ScreenTextField extends StatefulWidget {
  const ScreenTextField({
    super.key,
    required this.label,
    required this.ctrl,
    required this.hint,
    required this.fs,
    this.maxLines = 1,
  });
  final String label, hint;
  final TextEditingController ctrl;
  final double fs;
  final int maxLines;

  @override
  State<ScreenTextField> createState() => _ScreenTextFieldState();
}

class _ScreenTextFieldState extends State<ScreenTextField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final fs = widget.fs;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label, style: AppFonts.tvChannel(color: _focused ? colors.textSecondary : colors.textMuted, size: 7 * fs, letterSpacing: 2)),
      SizedBox(height: 4 * fs),
      Focus(
        onFocusChange: (v) => setState(() => _focused = v),
        child: TextField(
          controller: widget.ctrl,
          maxLines: widget.maxLines,
          style: AppFonts.code(color: colors.textPrimary, size: 9 * fs),
          cursorColor: colors.textSecondary,
          cursorWidth: 1.5,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppFonts.code(color: colors.textMuted, size: 9 * fs),
            filled: true,
            fillColor: _focused ? colors.tvAccent.withOpacity(0.04) : colors.surfaceAlt.withOpacity(0.3),
            contentPadding: EdgeInsets.all(8 * fs),
            border: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.zero, borderSide: BorderSide(color: colors.tvAccent)),
          ),
        ),
      ),
    ]);
  }
}