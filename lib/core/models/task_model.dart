class TaskModel {
  final int taskId;
  final int? projectId;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String? deadline;
  final int? assignedUser;
  final String? assignedUserName;
  final String? assignedUserEmail;
  final String? projectName;

  TaskModel({
    required this.taskId,
    this.projectId,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    this.deadline,
    this.assignedUser,
    this.assignedUserName,
    this.assignedUserEmail,
    this.projectName,
  });

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) return value.toInt();

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      taskId: _toNullableInt(json['task_id'] ?? json['id']) ?? 0,
      projectId: _toNullableInt(
        json['project_id'] ?? json['projectId'],
      ),
      title: json['title'] ?? 'Untitled Task',
      description: json['description'] ?? 'No task description available.',
      status: json['status'] ?? 'pending',
      priority: json['priority'] ?? 'medium',
      deadline: json['deadline']?.toString(),
      assignedUser: _toNullableInt(
        json['assigned_user'] ??
            json['assignedUser'] ??
            json['assigned_user_id'] ??
            json['assignedUserId'],
      ),
      assignedUserName: json['assigned_user_name'] ??
          json['employee_name'] ??
          json['assignedUserName'] ??
          json['user_name'],
      assignedUserEmail: json['assigned_user_email'] ??
          json['employee_email'] ??
          json['assignedUserEmail'] ??
          json['user_email'],
      projectName: json['project_name'] ??
          json['projectName'] ??
          json['name'],
    );
  }

  TaskModel copyWith({
    String? title,
    String? description,
    String? status,
    String? priority,
    String? deadline,
    int? assignedUser,
    String? assignedUserName,
    String? assignedUserEmail,
    String? projectName,
  }) {
    return TaskModel(
      taskId: taskId,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      deadline: deadline ?? this.deadline,
      assignedUser: assignedUser ?? this.assignedUser,
      assignedUserName: assignedUserName ?? this.assignedUserName,
      assignedUserEmail: assignedUserEmail ?? this.assignedUserEmail,
      projectName: projectName ?? this.projectName,
    );
  }
}