class SkillGroupModel {
  const SkillGroupModel({
    required this.label,
    required this.skills,
    this.featured = false,
    this.reception = 3,
  });

  final String label;
  final List<String> skills;
  final bool featured;
  final int reception;

  factory SkillGroupModel.fromMap(Map<String, dynamic> map) {
    return SkillGroupModel(
      label: map['label'] as String,
      skills: List<String>.from(map['skills'] as List),
      featured: map['featured'] as bool? ?? false,
      reception: map['reception'] as int? ?? 3,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'skills': skills,
      'featured': featured,
      'reception': reception,
    };
  }
}