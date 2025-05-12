class UserAuth {
  final String id;
  final String name;
  final String email;
  final String hashedPassword;
  final String salt;
  final bool isVerified;
  final String? verificationToken;
  final String? resetToken;
  final DateTime? resetTokenExpiry;
  final DateTime createdAt;
  
  UserAuth({
    required this.id,
    required this.name,
    required this.email,
    required this.hashedPassword,
    required this.salt,
    required this.isVerified,
    this.verificationToken,
    this.resetToken,
    this.resetTokenExpiry,
    required this.createdAt,
  });
  
  UserAuth copyWith({
    String? name,
    String? email,
    String? hashedPassword,
    String? salt,
    bool? isVerified,
    String? verificationToken,
    String? resetToken,
    DateTime? resetTokenExpiry,
  }) {
    return UserAuth(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      hashedPassword: hashedPassword ?? this.hashedPassword,
      salt: salt ?? this.salt,
      isVerified: isVerified ?? this.isVerified,
      verificationToken: verificationToken,
      resetToken: resetToken,
      resetTokenExpiry: resetTokenExpiry,
      createdAt: createdAt,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'hashedPassword': hashedPassword,
      'salt': salt,
      'isVerified': isVerified,
      'verificationToken': verificationToken,
      'resetToken': resetToken,
      'resetTokenExpiry': resetTokenExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory UserAuth.fromJson(Map<String, dynamic> json) {
    return UserAuth(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      hashedPassword: json['hashedPassword'],
      salt: json['salt'],
      isVerified: json['isVerified'],
      verificationToken: json['verificationToken'],
      resetToken: json['resetToken'],
      resetTokenExpiry: json['resetTokenExpiry'] != null
          ? DateTime.parse(json['resetTokenExpiry'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
