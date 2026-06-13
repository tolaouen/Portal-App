import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../config/app_config.dart';
import '../models/api_validation_error.dart';
import '../models/auth_exception.dart';
import '../models/auth_token.dart';
import '../models/auth_user.dart';
import '../models/register_request.dart';
import '../storage/auth_token_storage.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository({http.Client? client, AuthTokenStorage? tokenStorage})
    : _client = client ?? http.Client(),
      _tokenStorage = tokenStorage ?? AuthTokenStorage();

  final http.Client _client;
  final AuthTokenStorage _tokenStorage;

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Future<http.Response> _postWithRetry({
    required Uri uri,
    required Map<String, String> headers,
    required Object body,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await _client
            .post(uri, headers: headers, body: body)
            .timeout(const Duration(seconds: 25));
      } on SocketException catch (error) {
        lastError = error;
        debugPrint('Auth POST socket error on attempt ${attempt + 1}: $error');
      } on TimeoutException catch (error) {
        lastError = error;
        debugPrint('Auth POST timeout on attempt ${attempt + 1}: $error');
      } on http.ClientException catch (error) {
        lastError = error;
        debugPrint('Auth POST client error on attempt ${attempt + 1}: $error');
      }
      if (attempt == 0) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    if (lastError is TimeoutException) {
      throw const AuthException(
        message: 'Server is taking too long to respond. Please try again.',
      );
    }
    if (lastError is SocketException) {
      throw const AuthException(
        message:
            'No internet connection or server is unreachable. Please check your network and try again.',
      );
    }
    if (lastError is http.ClientException) {
      throw const AuthException(
        message: 'Unable to reach server. Please try again.',
      );
    }

    throw const AuthException(
      message: 'Unable to complete request. Please try again.',
    );
  }

  Future<http.Response> _getWithRetry({
    required Uri uri,
    required Map<String, String> headers,
  }) async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await _client
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 25));
      } on SocketException catch (error) {
        lastError = error;
        debugPrint('Auth GET socket error on attempt ${attempt + 1}: $error');
      } on TimeoutException catch (error) {
        lastError = error;
        debugPrint('Auth GET timeout on attempt ${attempt + 1}: $error');
      } on http.ClientException catch (error) {
        lastError = error;
        debugPrint('Auth GET client error on attempt ${attempt + 1}: $error');
      }
      if (attempt == 0) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    if (lastError is TimeoutException) {
      throw const AuthException(
        message: 'Server is taking too long to respond. Please try again.',
      );
    }
    if (lastError is SocketException) {
      throw const AuthException(
        message:
            'No internet connection or server is unreachable. Please check your network and try again.',
      );
    }
    if (lastError is http.ClientException) {
      throw const AuthException(
        message: 'Unable to reach server. Please try again.',
      );
    }

    throw const AuthException(
      message: 'Unable to complete request. Please try again.',
    );
  }

  @override
  Future<AuthUser> getMe(String accessToken) async {
    final response = await _getWithRetry(
      uri: _uri(AppConfig.mePath),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return AuthUser.fromJson(_decodeJsonObject(response.body));
    }

    throw _buildException(response);
  }

  @override
  Future<void> saveToken(AuthToken token) => _tokenStorage.saveToken(token);

  @override
  Future<AuthToken?> readToken() => _tokenStorage.readToken();

  @override
  Future<void> clearToken() => _tokenStorage.clearToken();

  AuthToken _parseTokenResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return AuthToken.fromJson(_decodeJsonObject(response.body));
    }
    throw _buildException(response);
  }

  AuthException _buildException(http.Response response) {
    final json = _tryDecodeJsonObject(response.body);
    final message = json?['message'];
    if (message is String && message.trim().isNotEmpty) {
      return AuthException(message: message, statusCode: response.statusCode);
    }
    final detail = json?['detail'];
    if (detail is List) {
      final errors = detail
          .whereType<Map<String, dynamic>>()
          .map(ApiValidationError.fromJson)
          .toList();
      return AuthException.fromValidation(
        statusCode: response.statusCode,
        errors: errors,
      );
    }
    if (detail is String && detail.trim().isNotEmpty) {
      return AuthException(message: detail, statusCode: response.statusCode);
    }
    return AuthException(
      message: 'Request failed with status ${response.statusCode}',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decodeJsonObject(String source) {
    final decoded = jsonDecode(source);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw const AuthException(message: 'Invalid server response');
  }

  Map<String, dynamic>? _tryDecodeJsonObject(String source) {
    try {
      return _decodeJsonObject(source);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthToken> login({
    required String username,
    required String password,
  }) async {
    final response = await _postWithRetry(
      uri: _uri(AppConfig.loginPath),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'password',
        'username': username.trim(),
        'password': password,
        'scope': '',
      },
    );
    return _parseTokenResponse(response);
  }

  @override
  Future<AuthToken> register(RegisterRequest request) async {
    final response = await _postWithRetry(
      uri: _uri(AppConfig.registerPath),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );
    return _parseTokenResponse(response);
  }
}
