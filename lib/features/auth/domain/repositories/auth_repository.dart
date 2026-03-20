import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String userName,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Option<UserEntity>> getCurrentUser();

  Future<Option<String>> getAccessToken();

  Future<bool> get isLoggedIn;
}
