class Experience {
  final String id;
  final String company;
  final String position;
  final String location;
  final String startDate;
  final String? endDate;
  final bool isCurrent;
  final List<String> description;
  final int order;

  const Experience({
    required this.id,
    required this.company,
    required this.position,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.isCurrent,
    required this.description,
    required this.order,
  });
}
