enum ProjectCategory {
  personal('PERSONAL'),
  freelance('FREELANCE');

  const ProjectCategory(this.label);
  final String label;
}

class ProjectModel {
  const ProjectModel({
    required this.index,
    required this.title,
    required this.year,
    required this.description,
    required this.techStack,
    this.role,
    this.githubUrl,
    this.playStoreUrl,
    this.urlLink,
    this.category,
    this.thumbnailAsset,
    this.screenshots,
  });

  final String index;
  final String title;
  final String year;
  final String description;
  final List<String> techStack;
  final List<String>? screenshots;
  final String? role;
  final String? githubUrl;
  final String? playStoreUrl;
  final String? urlLink;
  final String? thumbnailAsset;
  final ProjectCategory? category;

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      index: map['index'] as String,
      title: map['title'] as String,
      year: map['year'] as String,
      description: map['description'] as String,
      techStack: List<String>.from(map['techStack'] as List),
      role: map['role'] as String?,
      githubUrl: map['githubUrl'] as String?,
      playStoreUrl: map['playStoreUrl'] as String?,
      urlLink: map['urlLink'] as String?,
      thumbnailAsset: map['thumbnailAsset'] as String?,
      category: map['category'] != null
          ? ProjectCategory.values.firstWhere(
            (e) => e.toString() == map['category'],
        orElse: () => ProjectCategory.personal,
      ) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'index': index,
      'title': title,
      'year': year,
      'description': description,
      'techStack': techStack,
      'role': role,
      'githubUrl': githubUrl,
      'playStoreUrl': playStoreUrl,
      'urlLink': urlLink,
      'thumbnailAsset': thumbnailAsset,
      'category': category?.toString(),
    };
  }
}