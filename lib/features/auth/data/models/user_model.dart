import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.userName,
    super.displayName,
    super.email,
    this.accessToken,
    this.refreshToken,
  });

  final String? accessToken;
  final String? refreshToken;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? json['username'] as String? ?? '',
      displayName: json['displayName'] as String?,
      email: json['email'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userName': userName,
        'displayName': displayName,
        'email': email,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
