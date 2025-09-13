class UserModel {
  final String id;
  final String email;
  final String name;
  final String avatar;
  final int createdPlansCount;
  final double ratingAvg;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.avatar,
    this.createdPlansCount = 0,
    this.ratingAvg = 0.0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      avatar: map['avatar'] ?? '',
      createdPlansCount: map['createdPlansCount'] ?? 0,
      ratingAvg: (map['ratingAvg'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'createdPlansCount': createdPlansCount,
      'ratingAvg': ratingAvg,
    };
  }
}
