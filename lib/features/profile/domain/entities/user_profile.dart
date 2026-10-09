class UserProfile {
  final String uid;
  final String displayName;
  final String email;
  final String phone;
  final String location;
  final String linkedinUrl;
  final String githubUrl;
  final String websiteUrl;
  final String defaultTemplateId;
  final String defaultResumeTitle;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.phone = '',
    this.location = '',
    this.linkedinUrl = '',
    this.githubUrl = '',
    this.websiteUrl = '',
    this.defaultTemplateId = 'classic_01',
    this.defaultResumeTitle = 'My Resume',
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? displayName,
    String? email,
    String? phone,
    String? location,
    String? linkedinUrl,
    String? githubUrl,
    String? websiteUrl,
    String? defaultTemplateId,
    String? defaultResumeTitle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      linkedinUrl: linkedinUrl ?? this.linkedinUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      defaultTemplateId: defaultTemplateId ?? this.defaultTemplateId,
      defaultResumeTitle: defaultResumeTitle ?? this.defaultResumeTitle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
