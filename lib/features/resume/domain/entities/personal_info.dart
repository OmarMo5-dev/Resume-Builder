class PersonalInfo {
  final String fullName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String? linkedin;
  final String? github;
  final String? website;

  const PersonalInfo({
    required this.fullName,
    required this.jobTitle,
    required this.email,
    required this.phone,
    required this.location,
    this.linkedin,
    this.github,
    this.website,
  });
}