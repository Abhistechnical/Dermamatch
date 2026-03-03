// lib/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String planType;
  final int credits;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.planType,
    required this.credits,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      planType: json['plan_type'] ?? 'free',
      credits: json['credits'] ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'plan_type': planType,
        'credits': credits,
        'created_at': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? planType,
    int? credits,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      planType: planType ?? this.planType,
      credits: credits ?? this.credits,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isPro => planType == 'pro';
  bool get hasCredits => credits > 0;
}
