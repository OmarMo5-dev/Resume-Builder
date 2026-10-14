import '../../domain/entities/personal_info.dart';
import '../../domain/entities/resume_social_link.dart';

class PersonalInfoModel extends PersonalInfo {
  const PersonalInfoModel({
    required super.fullName,
    required super.jobTitle,
    required super.email,
    required super.phone,
    required super.location,
    super.linkedin,
    super.github,
    super.website,
    super.socialLinks = const [],
  });

  static PersonalInfoModel fromEntity(PersonalInfo e) => PersonalInfoModel(
        fullName: e.fullName,
        jobTitle: e.jobTitle,
        email: e.email,
        phone: e.phone,
        location: e.location,
        linkedin: e.linkedin,
        github: e.github,
        website: e.website,
        socialLinks: e.socialLinks,
      );

  factory PersonalInfoModel.fromMap(Map<String, dynamic> map) {
    final rawLinks = map['socialLinks'];
    return PersonalInfoModel(
      fullName: map['fullName'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      location: map['location'] as String? ?? '',
      linkedin: map['linkedin'] as String?,
      github: map['github'] as String?,
      website: map['website'] as String?,
      socialLinks: rawLinks is List
          ? rawLinks.whereType<Map>().map((item) => ResumeSocialLink(
                id: item['id']?.toString() ?? '',
                platform: item['platform']?.toString() ?? '',
                url: item['url']?.toString() ?? '',
              )).where((link) => link.platform.trim().isNotEmpty && link.url.trim().isNotEmpty).toList()
          : const [],
    );
  }

  Map<String, dynamic> toMap() => {
        'fullName': fullName,
        'jobTitle': jobTitle,
        'email': email,
        'phone': phone,
        'location': location,
        'linkedin': linkedin,
        'github': github,
        'website': website,
        'socialLinks': [
          for (final link in socialLinks)
            if (link.platform.trim().isNotEmpty && link.url.trim().isNotEmpty)
              {'id': link.id, 'platform': link.platform, 'url': link.url},
        ],
      };
}
