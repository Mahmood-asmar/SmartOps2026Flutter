class AppUserModel {
  final int userId;
  final String name;
  final String email;
  final String role;

  AppUserModel({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      userId: _toInt(json['user_id'] ?? json['id']),
      name: json['name']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'client',
    );
  }
}