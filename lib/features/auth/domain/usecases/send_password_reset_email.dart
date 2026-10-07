import '../repositories/auth_repository.dart';

class SendPasswordResetEmail {
  SendPasswordResetEmail(this._repository);
  final AuthRepository _repository;

  Future<void> call(String email) => _repository.sendPasswordResetEmail(email);
}
