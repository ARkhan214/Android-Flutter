class Profile {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String photo;
  final String dateOfBirth;
  final String role;
  final bool active;
  final bool enabled;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.photo,
    required this.dateOfBirth,
    required this.role,
    required this.active,
    required this.enabled,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? '',
      photo: json['photo'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      role: json['role'] ?? '',
      active: json['active'] ?? false,
      enabled: json['enabled'] ?? false,
    );
  }
}
