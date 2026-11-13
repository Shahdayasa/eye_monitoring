class AppException implements Exception {
  final String message;
  final String? code;

  AppException({required this.message, this.code});

  @override
  String toString() => 'AppException($code): $message';
}

class NetworkException extends AppException {
  NetworkException({super.message = 'Network error occurred', super.code});
}

class AuthenticationException extends AppException {
  AuthenticationException({super.message = 'Authentication failed', super.code});
}

class DataNotFoundException extends AppException {
  DataNotFoundException({super.message = 'Data not found', super.code});
}
