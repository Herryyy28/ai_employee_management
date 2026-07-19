import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  String toString() => 'Failure(message: $message, statusCode: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message) : super(statusCode: 503);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message) : super(statusCode: 401);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message) : super(statusCode: 422);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

// Helper to convert DioException or general Exceptions to Failures
class FailureHandler {
  FailureHandler._();

  static Failure handle(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const NetworkFailure('Connection timed out. Please try again.');
        case DioExceptionType.badResponse:
          final code = error.response?.statusCode;
          final dynamic data = error.response?.data;
          final msg = (data is Map && data.containsKey('message')) 
              ? data['message'].toString() 
              : 'Server returned error status $code';
          if (code == 401 || code == 403) {
            return AuthFailure(msg);
          }
          if (code == 422) {
            return ValidationFailure(msg);
          }
          return ServerFailure(msg, statusCode: code);
        case DioExceptionType.cancel:
          return const UnknownFailure('Request was cancelled.');
        case DioExceptionType.connectionError:
          return const NetworkFailure('No internet connection detected.');
        default:
          return UnknownFailure(error.message ?? 'A network communication error occurred.');
      }
    }
    
    return UnknownFailure(error.toString());
  }
}
