import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.role,
    required super.description,
    required super.technologies,
    super.githubUrl,
    super.liveUrl,
    required super.order,
  });

  static ProjectModel fromEntity(Project e) => ProjectModel(id:e.id,name:e.name,role:e.role,description:e.description,technologies:e.technologies,githubUrl:e.githubUrl,liveUrl:e.liveUrl,order:e.order);

  factory ProjectModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return ProjectModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      role: map['role'] as String? ?? '',
      description: _strings(map['description']),
      technologies: _strings(map['technologies']),
      githubUrl: map['githubUrl'] as String?,
      liveUrl: map['liveUrl'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'description': description,
      'technologies': technologies,
      'githubUrl': githubUrl,
      'liveUrl': liveUrl,
      'order': order,
    };
  }

  static List<String> _strings(Object? raw) {
    final out = <String>[];
    if (raw is Iterable) {
      for (final item in raw) {
        if (item != null) out.add(item.toString());
      }
    }
    return out;
  }
}
