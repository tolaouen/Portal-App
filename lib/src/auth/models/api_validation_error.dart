class ApiValidationError {
  const ApiValidationError({
    required this.location,
    required this.message,
    required this.type,
  });

  final List<Object?> location;
  final String message;
  final String type;

  factory ApiValidationError.fromJson(Map<String, dynamic> json) {
    return ApiValidationError(
      location: (json['loc'] as List<dynamic>? ?? const []).cast<Object?>(),
      message: json['msg'] as String? ?? 'Validation error',
      type: json['type'] as String? ?? 'validation_error',
    );
  }

  String get fieldName {
    if (location.isEmpty) {
      return '';
    }
    final last = location.last;
    return last == null ? '' : last.toString();
  }
}
