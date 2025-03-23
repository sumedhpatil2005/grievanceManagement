class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? department;
  final String? year; // 'student', 'moderator', 'principal'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.year,
    this.department,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      name: data['name'],
      email: data['email'],
      role: data['role'],
      department: data['role'] == 'principal' ? null : data['department'],
      year: data['year'] == 'principal' ? null : data['year'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'department': department,
      'year': year,
    };
  }
}
