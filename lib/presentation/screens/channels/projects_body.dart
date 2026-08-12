import 'package:flutter/material.dart';
import '../../../data/repositories/portfolio_repository.dart';
import '../../widgets/sections/project_row.dart';

class ProjectsBody extends StatelessWidget {
  const ProjectsBody({super.key, required this.fs});
  final double fs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(12 * fs, 20 * fs, 12 * fs, 14 * fs),
      child: Column(
        children: PortfolioRepository.sideProjects.map((p) {
          return ProjectRow(
            project: p,
            fs: fs,
          );
        }).toList(),
      ),
    );
  }
}