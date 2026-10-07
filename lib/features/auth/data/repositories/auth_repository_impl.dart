import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  AppUser _mapUser(UserCredential credential) {
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-null',
        message: 'Authentication succeeded but no user was returned.',
      );
    }
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Stream<AppUser?> get authStateChanges => _remoteDataSource.authStateChanges.map(
        (user) => user == null ? null : UserModel.fromFirebaseUser(user),
      );

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    return _mapUser(await _remoteDataSource.signIn(
      email: email,
      password: password,
    ));
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    return _mapUser(await _remoteDataSource.register(
      email: email,
      password: password,
    ));
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    return _mapUser(await _remoteDataSource.signInWithGoogle());
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendEmailVerification() {
    return _remoteDataSource.sendEmailVerification();
  }

  @override
  Future<void> signOut() {
    return _remoteDataSource.signOut();
  }
}
