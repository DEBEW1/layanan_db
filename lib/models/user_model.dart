class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id_warga']?.toString() ?? json['id']?.toString() ?? '',
      name: json['nama'] ?? '',
      email: json['email'] ?? '',
      phone: json['telepon'] ?? '',
      role: json['role'] ?? 'warga',
    );
  }
}