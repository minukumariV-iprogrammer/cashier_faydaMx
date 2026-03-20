import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/token_holder.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote, this._local, this._tokenHolder);

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final TokenHolder _tokenHolder;

  @override
  Future<Either<Failure, UserEntity>> login({
    required String userName,
    required String password,
  }) async {
    // Demo login for development (matches design placeholder)
    const demoUser = 'demo453';
    const demoPass = 'demo453';
    if (userName.trim() == demoUser && password == demoPass) {
      final user = UserModel(
        id: 'demo-1',
        userName: demoUser,
        displayName: 'Demo User',
        accessToken: 'demo-token',
      );
      await _local.saveUser(user);
      await _local.saveTokens(accessToken: user.accessToken);
      _tokenHolder.setToken(user.accessToken);
      return Right(user);
    }

    try {
      final user = await _remote.login(
        userName: userName,
        password: password,
      );
      await _local.saveUser(user);
      if (user.accessToken != null) {
        await _local.saveTokens(accessToken: user.accessToken);
        _tokenHolder.setToken(user.accessToken);
      }
      return Right(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(AuthFailure('Invalid credentials'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      _tokenHolder.clear();
      await _local.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Option<UserEntity>> getCurrentUser() async {
    final user = await _local.getSavedUser();
    return optionOf(user);
  }

  @override
  Future<Option<String>> getAccessToken() async {
    final token = await _local.getAccessToken();
    return optionOf(token);
  }

  @override
  Future<bool> get isLoggedIn async {
    final token = await _local.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
