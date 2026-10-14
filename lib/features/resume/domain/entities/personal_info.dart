import 'resume_social_link.dart';

class PersonalInfo {
  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String? linkedin;
  final String? github;
  final String? website;
  /// Additional optional links for professions that use other platforms.
  /// Existing LinkedIn/GitHub/website fields remain for backwards compatibility.
  final List<ResumeSocialLink> socialLinks;

  const PersonalInfo({
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedin,
    this.github,
    this.website,
    this.socialLinks = const [],
  });
}
