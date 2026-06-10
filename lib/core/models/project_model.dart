class ProjectModel {
  final int projectId;
  final String name;
  final String description;
  final int? clientId;
  final String? clientName;
  final int? templateId;
  final String? templateName;
  final String category;
  final String status;
  final String priority;
  final String? startDate;
  final String? deadline;
  final String? createdAt;
  final String? createdByName;

  ProjectModel({
    required this.projectId,
    required this.name,
    required this.description,
    this.clientId,
    this.clientName,
    this.templateId,
    this.templateName,
    required this.category,
    required this.status,
    required this.priority,
    this.startDate,
    this.deadline,
    this.createdAt,
    this.createdByName,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projectId: json['project_id'] ?? json['id'] ?? 0,
      name: json['name'] ??
          json['project_name'] ??
          json['projectName'] ??
          'Untitled Project',
      description: json['description'] ?? 'No project description available.',
      clientId: json['client_id'],
      clientName: json['client_name'] ?? json['clientName'],
      templateId: json['template_id'],
      templateName: json['template_name'] ?? json['templateName'],
      category: json['category'] ?? 'Uncategorized',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      startDate: json['start_date']?.toString(),
      deadline: json['deadline']?.toString(),
      createdAt: json['created_at']?.toString(),
      createdByName: json['created_by_name'] ?? json['createdByName'],
    );
  }

  ProjectModel copyWith({
    String? status,
    String? priority,
  }) {
    return ProjectModel(
      projectId: projectId,
      name: name,
      description: description,
      clientId: clientId,
      clientName: clientName,
      templateId: templateId,
      templateName: templateName,
      category: category,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate,
      deadline: deadline,
      createdAt: createdAt,
      createdByName: createdByName,
    );
  }
}