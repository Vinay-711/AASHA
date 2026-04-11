import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteSource remoteSource;
  final LocalStorage localStorage;

  AuthRepositoryImpl({required this.remoteSource, required this.localStorage});

  Future<(String?, Failure?)> login(String phone, String password) async {
    try {
      final token = await remoteSource.login(phone, password);
      await localStorage.saveToken(token);
      return (token, null);
    } on ServerException {
      return (null, ServerFailure('Login failed. Check credentials.'));
    }
  }

  Future<(String?, Failure?)> register(
      String name, String phone, String password) async {
    try {
      final userId = await remoteSource.register(name, phone, password);
      return (userId, null);
    } on ServerException {
      return (null, ServerFailure('Registration failed. Try again.'));
    }
  }
}
