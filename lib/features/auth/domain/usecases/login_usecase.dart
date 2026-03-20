import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call({
    required String userName,
    required String password,
  }) =>
      _repository.login(userName: userName, password: password);
}
