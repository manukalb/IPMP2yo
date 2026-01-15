class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String? message])
      : super(message ?? 'Error de conexión. Verifica tu internet.');
}

class ServerException extends AppException {
  ServerException([String? message])
      : super(message ?? 'Error del servidor. Inténtalo más tarde.');
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}

class NotFoundException extends AppException {
  NotFoundException([String? message])
      : super(message ?? 'Recurso no encontrado.');
}
