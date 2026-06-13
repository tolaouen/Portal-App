import '../models/auth_token.dart';
import '../models/auth_user.dart';
import '../models/register_request.dart';

abstract class AuthRepository {
  Future<AuthToken> login({required String username, required String password});

  Future<AuthToken> register(RegisterRequest request);

  Future<AuthUser> getMe(String accessToken);

  Future<void> saveToken(AuthToken token);

  Future<AuthToken?> readToken();

  Future<void> clearToken();
}
