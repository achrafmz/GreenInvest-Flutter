class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? keycloakUserId;
  final DateTime? dateInscription;
  final double? solde; // Pour les investisseurs

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.keycloakUserId,
    this.dateInscription,
    this.solde,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      role: json['role'],
      keycloakUserId: json['keycloakUserId'],
      dateInscription: json['dateInscription'] != null 
          ? DateTime.parse(json['dateInscription']) 
          : null,
      solde: json['solde']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'keycloakUserId': keycloakUserId,
      'dateInscription': dateInscription?.toIso8601String(),
      'solde': solde,
    };
  }
}