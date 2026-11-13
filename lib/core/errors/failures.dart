abstract class Failure {
  final String message;

  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({super.message = 'Server error occurred'});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Network connection error'});
}

class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Authentication failed'});
}

class CacheFailure extends Failure {
  const CacheFailure({super.message = 'Cache error occurred'});
}
