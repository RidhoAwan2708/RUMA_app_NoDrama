enum UserRole { civitas, teknisi, admin }

class RumaUser {
  final String uid;
  final String email;
  final String name;
  final String nimNip;
  final UserRole role;
  final String? photoUrl;
  final String? phone;
  final String? jurusan;
  final DateTime createdAt;

  RumaUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.nimNip,
    required this.role,
    this.photoUrl,
    this.phone,
    this.jurusan,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'name': name,
        'nimNip': nimNip,
        'role': role.name,
        'photoUrl': photoUrl,
        'phone': phone,
        'jurusan': jurusan,
        'createdAt': createdAt.toIso8601String(),
      };

  factory RumaUser.fromMap(Map<String, dynamic> map) => RumaUser(
        uid: map['uid'] as String,
        email: map['email'] as String,
        name: map['name'] as String,
        nimNip: map['nimNip'] as String,
        role: UserRole.values.firstWhere((r) => r.name == map['role']),
        photoUrl: map['photoUrl'] as String?,
        phone: map['phone'] as String?,
        jurusan: map['jurusan'] as String?,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : null,
      );

  bool get isAdmin => role == UserRole.admin;
  bool get isTeknisi => role == UserRole.teknisi;
  bool get isCivitas => role == UserRole.civitas;
}
