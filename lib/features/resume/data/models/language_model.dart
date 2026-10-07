import '../../domain/entities/language.dart';

class LanguageModel extends Language {
  const LanguageModel({
    required super.id,
    required super.name,
    required super.level,
    required super.order,
  });

  static LanguageModel fromEntity(Language e) => LanguageModel(id:e.id,name:e.name,level:e.level,order:e.order);

  factory LanguageModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return LanguageModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      level: map['level'] as String? ?? '',
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'order': order,
    };
  }
}