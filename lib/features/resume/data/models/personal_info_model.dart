import '../../domain/entities/personal_info.dart';

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
  });

  static PersonalInfoModel fromEntity(PersonalInfo e) => PersonalInfoModel(fullName:e.fullName,jobTitle:e.jobTitle,email:e.email,phone:e.phone,location:e.location,linkedin:e.linkedin,github:e.github,website:e.website);

  factory PersonalInfoModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return PersonalInfoModel(
      fullName: map['fullName'] as String? ?? '',
      jobTitle: map['jobTitle'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      location: map['location'] as String? ?? '',
      linkedin: map['linkedin'] as String?,
      github: map['github'] as String?,
      website: map['website'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedin': linkedin,
      'github': github,
      'website': website,
    };
  }
}