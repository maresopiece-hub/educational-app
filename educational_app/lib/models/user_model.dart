import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class AppUser {
  final String id;
  final String email;
  final String name;
  final Map<String, double> progress;
  final List<String> plans;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.progress = const {},
    this.plans = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);
  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}
