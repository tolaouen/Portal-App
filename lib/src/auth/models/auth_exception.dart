import 'api_validation_error.dart';

class AuthException implements Exception {
  const AuthException({
    required this.message,
    this.statusCode,
    this.errors = const [],
  });

  final String message;
  final int? statusCode;
  final List<ApiValidationError> errors;

  factory AuthException.fromValidation({
    required int statusCode,
    required List<ApiValidationError> errors,
  }) {
    final messages = errors.map((error) {
      final field = error.fieldName;
      if (field.isEmpty) {
        return error.message;
      }
      return '${_prettify(field)}: ${error.message}';
    }).toList();
    return AuthException(
      message: messages.isEmpty ? 'Validation error' : messages.join('\n'),
      statusCode: statusCode,
      errors: errors,
    );
  }

  static String _prettify(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  @override
  String toString() => message;
}
