import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.emailVerified,
  });

  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
    );
  }
}
