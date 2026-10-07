class Project {
  final String id;
  final String name;
  final String role;
  final List<String> description;
  final List<String> technologies;
  final String? githubUrl;
  final String? liveUrl;
  final int order;

  const Project({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.technologies,
    this.githubUrl,
    this.liveUrl,
    required this.order,
  });
}
