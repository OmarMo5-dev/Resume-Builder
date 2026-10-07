import '../entities/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> get authStateChanges;

  Future<AppUser> signIn({
    required String email,
    required String password,
  });

  Future<AppUser> register({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> sendEmailVerification();

  Future<void> signOut();
}
