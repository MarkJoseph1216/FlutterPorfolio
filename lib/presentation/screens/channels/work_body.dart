import 'package:flutter/material.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../widgets/sections/project_row.dart';

class WorkBody extends StatelessWidget {
  const WorkBody({super.key, required this.fs});
  final double fs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12 * fs, 0, 12 * fs, 14 * fs),
      child: Column(
        children: PortfolioRepository.projects.asMap().entries.map((e) {
          final p = e.value;
          return ProjectRow(
            number: p.index,
            title: p.title,
            role: p.role,
            description: p.description,
            tech: p.techStack.take(3).join(' · '),
            year: p.year,
            url: p.playStoreUrl,
            thumbnailAsset: p.thumbnailAsset,
            fs: fs,
          );
        }).toList(),
      ),
    );
  }
}