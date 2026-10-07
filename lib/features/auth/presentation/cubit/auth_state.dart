import '../../domain/entities/app_user.dart';

enum AuthStatus { initial, authLoading, googleLoading,  authenticated, unauthenticated, failure }

class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final AppUser? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    String? message,
    bool clearMessage = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
