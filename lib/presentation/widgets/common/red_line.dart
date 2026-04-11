import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RedLine extends StatelessWidget {
  const RedLine({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(child: Container(width: 30, height: 1, color: colors.tvAccent.withOpacity(0.3)));
  }
}