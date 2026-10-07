import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  SignInWithGoogle(this._repository);
  final AuthRepository _repository;

  Future<AppUser> call() => _repository.signInWithGoogle();
}
