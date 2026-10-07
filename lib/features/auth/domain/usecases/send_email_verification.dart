import '../repositories/auth_repository.dart';

class SendEmailVerification {
  SendEmailVerification(this._repository);
  final AuthRepository _repository;

  Future<void> call() => _repository.sendEmailVerification();
}
