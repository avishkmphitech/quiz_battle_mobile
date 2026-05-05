/// Logged-in user subset returned by `backend` auth controllers.
final class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.mobile,
  });

  final String id;
  final String name;
  final String email;
  final String role;
  final String? mobile;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final m = json['mobile'];
    return AuthUser(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      mobile: m == null ? null : m.toString().trim().isEmpty ? null : m.toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        if (mobile != null) 'mobile': mobile,
      };
}
