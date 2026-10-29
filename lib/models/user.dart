class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromMap(Map<String, Object?> map) => AppUser(
        id: map['id'] as int,
        name: map['name'] as String,
        email: map['email'] as String,
        role: map['role'] as String,
      );
}
