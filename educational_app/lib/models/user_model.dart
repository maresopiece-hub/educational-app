class UserModel {
  final String id;
  final String email;
  final String name;
  final List<String> plans;
  final Map<String, double> progress;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.plans,
    required this.progress,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      plans: List<String>.from(json['plans'] ?? []),
      progress: (json['progress'] as Map<String, dynamic>? ?? {})
        .map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'plans': plans,
      'progress': progress,
    };
  }
}
