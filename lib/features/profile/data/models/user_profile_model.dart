import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.uid,
    required super.displayName,
    required super.email,
    super.phone,
    super.location,
    super.linkedinUrl,
    super.githubUrl,
    super.websiteUrl,
    super.defaultTemplateId,
    super.defaultResumeTitle,
    super.createdAt,
    super.updatedAt,
  });

  factory UserProfileModel.fromDoc(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};

    DateTime? date(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    String stringValue(String key, [String fallback = '']) {
      final value = data[key];
      return value is String ? value : fallback;
    }

    return UserProfileModel(
      uid: document.id,
      displayName: stringValue('displayName'),
      email: stringValue('email'),
      phone: stringValue('phone'),
      location: stringValue('location'),
      linkedinUrl: stringValue('linkedinUrl'),
      githubUrl: stringValue('githubUrl'),
      websiteUrl: stringValue('websiteUrl'),
      defaultTemplateId: stringValue('defaultTemplateId', 'classic_01'),
      defaultResumeTitle: stringValue('defaultResumeTitle', 'My Resume'),
      createdAt: date(data['createdAt']),
      updatedAt: date(data['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedinUrl': linkedinUrl,
      'githubUrl': githubUrl,
      'websiteUrl': websiteUrl,
      'defaultTemplateId': defaultTemplateId,
      'defaultResumeTitle': defaultResumeTitle,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(updatedAt!),
    };
  }
}
