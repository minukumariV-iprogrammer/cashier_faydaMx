import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String userName, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<UserModel> login({
    required String userName,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'userName': userName, 'password': password},
    );
    if (response.data == null) {
      throw Exception('Invalid response');
    }
    return UserModel.fromJson(response.data!);
  }
}
