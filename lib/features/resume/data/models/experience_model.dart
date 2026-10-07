import '../../domain/entities/experience.dart';

class ExperienceModel extends Experience {
  const ExperienceModel({
    required super.id,
    required super.company,
    required super.position,
    required super.location,
    required super.startDate,
    super.endDate,
    required super.isCurrent,
    required super.description,
    required super.order,
  });

  static ExperienceModel fromEntity(Experience e) => ExperienceModel(id:e.id,company:e.company,position:e.position,location:e.location,startDate:e.startDate,endDate:e.endDate,isCurrent:e.isCurrent,description:e.description,order:e.order);

  factory ExperienceModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return ExperienceModel(
      id: map['id'] as String? ?? '',
      company: map['company'] as String? ?? '',
      position: map['position'] as String? ?? '',
      location: map['location'] as String? ?? '',
      startDate: map['startDate'] as String? ?? '',
      endDate: map['endDate'] as String?,
      isCurrent: map['isCurrent'] as bool? ?? false,
      description: _strings(map['description']),
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'isCurrent': isCurrent,
      'description': description,
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
