enum ProjectCategory { freelance, personal }

extension ProjectCategoryLabel on ProjectCategory {
  String get label {
    switch (this) {
      case ProjectCategory.freelance:
        return 'Freelance';
      case ProjectCategory.personal:
        return 'Personal';
    }
  }
}

class ProjectModel {
  const ProjectModel({
    required this.index,
    required this.title,
    required this.year,
    required this.description,
    required this.techStack,
    this.role,
    this.category,
    this.thumbnailAsset,
    this.urlLink,
    this.githubUrl,
    this.playStoreUrl,
  });

  final String index;
  final String title;
  final String year;
  final String? role;
  final String description;
  final List<String> techStack;
  final ProjectCategory? category;
  final String? thumbnailAsset;
  final String? urlLink;
  final String? githubUrl;
  final String? playStoreUrl;
}
