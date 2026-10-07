import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/register.dart';
import '../../domain/usecases/send_email_verification.dart';
import '../../domain/usecases/send_password_reset_email.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required SignIn signIn,
    required Register register,
    required SignInWithGoogle signInWithGoogle,
    required SendPasswordResetEmail sendPasswordResetEmail,
    required SendEmailVerification sendEmailVerification,
    required SignOut signOut,
    required Stream<AppUser?> authStateChanges,
  }) : _signIn = signIn,
       _register = register,
       _signInWithGoogle = signInWithGoogle,
       _sendPasswordResetEmail = sendPasswordResetEmail,
       _sendEmailVerification = sendEmailVerification,
       _signOut = signOut,
       super(const AuthState()) {
    _authSubscription = authStateChanges.listen(_onAuthChanged);
  }

  final SignIn _signIn;
  final Register _register;
  final SignInWithGoogle _signInWithGoogle;
  final SendPasswordResetEmail _sendPasswordResetEmail;
  final SendEmailVerification _sendEmailVerification;
  final SignOut _signOut;

  late final StreamSubscription<AppUser?> _authSubscription;

  void _onAuthChanged(AppUser? user) {
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.authLoading, clearMessage: true));

    try {
      await _signIn(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.message ?? e.code,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.toString()));
    }
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    emit(state.copyWith(status: AuthStatus.authLoading, clearMessage: true));

    try {
      final user = await _register(email: email, password: password);

      if (!user.emailVerified) {
        await _sendEmailVerification();
      }
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.message ?? e.code,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.toString()));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(state.copyWith(status: AuthStatus.googleLoading, clearMessage: true));

    try {
      await _signInWithGoogle();
    } on GoogleSignInException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.description ?? e.code.name,
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.message ?? e.code,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.toString()));
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    emit(state.copyWith(status: AuthStatus.authLoading, clearMessage: true));
    try {
      await _sendPasswordResetEmail(email);
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          message: 'Password reset email sent.',
        ),
      );
    } on FirebaseAuthException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.message ?? e.code,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.failure, message: e.toString()));
    }
  }

  Future<void> signOut() async {
    if (isClosed) return;
    emit(state.copyWith(status: AuthStatus.authLoading, clearMessage: true));

    try {
      await _signOut();
      if (isClosed) return;
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } on FirebaseAuthException catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: e.message ?? e.code,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: AuthStatus.failure, message: e.toString()));
    }
  }


  @override
  Future<void> close() async {
    await _authSubscription.cancel();
    return super.close();
  }
}
