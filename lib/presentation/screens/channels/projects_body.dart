import 'package:flutter/material.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../widgets/sections/project_row.dart';

class ProjectsBody extends StatelessWidget {
  const ProjectsBody({super.key, required this.fs});
  final double fs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12 * fs, 0, 12 * fs, 14 * fs),
      child: Column(
        children: PortfolioRepository.sideProjects.asMap().entries.map((e) {
          final p = e.value;
          return ProjectRow(
            number: p.index,
            title: p.title,
            role: p.role ?? '',
            description: p.description,
            tech: p.techStack.take(3).join(' · '),
            year: p.year,
            category: p.category?.label,
            url: p.urlLink ?? p.playStoreUrl,
            thumbnailAsset: p.thumbnailAsset,
            fs: fs,
          );
        }).toList(),
      ),
    );
  }
}