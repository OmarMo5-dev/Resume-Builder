import '../../domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.name,
    required super.provider,
    required super.date,
    super.description,
    super.credentialUrl,
    required super.order,
  });

  factory CourseModel.fromEntity(Course e) => CourseModel(
        id: e.id,
        name: e.name,
        provider: e.provider,
        date: e.date,
        description: e.description,
        credentialUrl: e.credentialUrl,
        order: e.order,
      );

  factory CourseModel.fromMap(Map<String, dynamic> map) => CourseModel(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        provider: map['provider'] as String? ?? '',
        date: map['date'] as String? ?? '',
        description: map['description'] as String?,
        credentialUrl: map['credentialUrl'] as String?,
        order: (map['order'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'provider': provider,
        'date': date,
        'description': description,
        'credentialUrl': credentialUrl,
        'order': order,
      };
}
