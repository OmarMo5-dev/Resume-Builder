import '../../domain/entities/education.dart';

class EducationModel extends Education {
  const EducationModel({
    required super.id,
    required super.institution,
    required super.degree,
    required super.location,
    required super.startDate,
    super.endDate,
    required super.isCurrent,
    super.description,
    required super.order,
  });

  static EducationModel fromEntity(Education e) => EducationModel(id:e.id,institution:e.institution,degree:e.degree,location:e.location,startDate:e.startDate,endDate:e.endDate,isCurrent:e.isCurrent,description:e.description,order:e.order);

  factory EducationModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return EducationModel(
      id: map['id'] as String? ?? '',
      institution: map['institution'] as String? ?? '',
      degree: map['degree'] as String? ?? '',
      location: map['location'] as String? ?? '',
      startDate: map['startDate'] as String? ?? '',
      endDate: map['endDate'] as String?,
      isCurrent: map['isCurrent'] as bool? ?? false,
      description: map['description'] as String?,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'institution': institution,
      'degree': degree,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'isCurrent': isCurrent,
      'description': description,
      'order': order,
    };
  }
}