import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile_model.dart';

class ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  ProfileRemoteDataSource({required this.firestore, required this.auth});

  String get uid {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('User is not authenticated.');
    }
    return currentUser.uid;
  }

  DocumentReference<Map<String, dynamic>> get ref =>
      firestore.collection('users').doc(uid);

  Future<UserProfileModel> getProfile() async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw Exception('User is not authenticated.');
    }

    var document = await ref.get();
    if (!document.exists) {
      await ref.set({
        'displayName': currentUser.displayName ?? '',
        'email': currentUser.email ?? '',
        'phone': currentUser.phoneNumber ?? '',
        'location': '',
        'linkedinUrl': '',
        'githubUrl': '',
        'websiteUrl': '',
        'defaultTemplateId': 'classic_01',
        'defaultResumeTitle': 'My Resume',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      document = await ref.get();
    }

    return UserProfileModel.fromDoc(document);
  }

  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    await ref.set(profile.toMap(), SetOptions(merge: true));

    final currentUser = auth.currentUser;
    if (currentUser != null &&
        currentUser.displayName != profile.displayName.trim()) {
      await currentUser.updateDisplayName(profile.displayName.trim());
    }

    final document = await ref.get();
    return UserProfileModel.fromDoc(document);
  }
}
