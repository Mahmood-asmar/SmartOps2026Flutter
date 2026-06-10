class ProjectRequestModel {
  final int requestId;
  final int? clientId;
  final int? templateId;
  final String name;
  final String description;
  final String category;
  final int estimatedDuration;
  final String? deadline;
  final String status;
  final String? clientName;
  final String? templateName;
  final String? rejectionReason;
  final String? createdAt;
  final int? reviewedBy;

  ProjectRequestModel({
    required this.requestId,
    this.clientId,
    this.templateId,
    required this.name,
    required this.description,
    required this.category,
    required this.estimatedDuration,
    this.deadline,
    required this.status,
    this.clientName,
    this.templateName,
    this.rejectionReason,
    this.createdAt,
    this.reviewedBy,
  });

  factory ProjectRequestModel.fromJson(Map<String, dynamic> json) {
    return ProjectRequestModel(
      requestId: json['request_id'] ?? json['id'] ?? 0,
      clientId: json['client_id'],
      templateId: json['template_id'],
      name: json['name'] ??
          json['project_name'] ??
          json['projectName'] ??
          'Untitled Request',
      description: json['description'] ?? 'No request description available.',
      category: json['category'] ?? 'Uncategorized',
      estimatedDuration:
      int.tryParse('${json['estimated_duration'] ?? 0}') ?? 0,
      deadline: json['deadline']?.toString(),
      status: json['status'] ?? 'pending',
      clientName: json['client_name'] ?? json['clientName'],
      templateName: json['template_name'] ?? json['templateName'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at']?.toString(),
      reviewedBy: json['reviewed_by'],
    );
  }

  ProjectRequestModel copyWith({
    String? status,
    String? rejectionReason,
    String? deadline,
  }) {
    return ProjectRequestModel(
      requestId: requestId,
      clientId: clientId,
      templateId: templateId,
      name: name,
      description: description,
      category: category,
      estimatedDuration: estimatedDuration,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      clientName: clientName,
      templateName: templateName,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt,
      reviewedBy: reviewedBy,
    );
  }
}