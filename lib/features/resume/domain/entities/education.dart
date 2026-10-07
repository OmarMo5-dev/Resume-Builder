class Education {
  final String id;
  final String institution;
  final String degree;
  final String location;
  final String startDate;
  final String? endDate;
  final bool isCurrent;
  final String? description;
  final int order;

  const Education({
    required this.id,
    required this.institution,
    required this.degree,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    this.description,
    required this.order,
  });
}
