import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.userName,
    this.displayName,
    this.email,
  });

  final String id;
  final String userName;
  final String? displayName;
  final String? email;

  @override
  List<Object?> get props => [id, userName, displayName, email];
}
