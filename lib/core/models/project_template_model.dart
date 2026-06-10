class ProjectTemplateModel {
  final int templateId;
  final String name;
  final String description;
  final String category;
  final int estimatedDuration;
  final int? createdBy;
  final String? createdAt;

  ProjectTemplateModel({
    required this.templateId,
    required this.name,
    required this.description,
    required this.category,
    required this.estimatedDuration,
    this.createdBy,
    this.createdAt,
  });

  factory ProjectTemplateModel.fromJson(Map<String, dynamic> json) {
    return ProjectTemplateModel(
      templateId: json['template_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? 'Untitled Template',
      description: json['description'] ?? 'No description available.',
      category: json['category'] ?? 'Uncategorized',
      estimatedDuration: int.tryParse('${json['estimated_duration'] ?? 0}') ?? 0,
      createdBy: json['created_by'],
      createdAt: json['created_at']?.toString(),
    );
  }
}