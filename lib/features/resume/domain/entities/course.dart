class Course {
  final String id;
  final String name;
  final String provider;
  final String date;
  final String? description;
  final String? credentialUrl;
  final int order;

  const Course({
    required this.id,
    required this.name,
    required this.provider,
    required this.date,
    this.description,
    this.credentialUrl,
    required this.order,
  });
}
