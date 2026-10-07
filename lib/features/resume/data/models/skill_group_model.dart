import '../../domain/entities/skill_group.dart';

class SkillGroupModel extends SkillGroup {
  const SkillGroupModel({
    required super.id,
    required super.category,
    required super.items,
    required super.order,
  });

  static SkillGroupModel fromEntity(SkillGroup e) => SkillGroupModel(id:e.id,category:e.category,items:e.items,order:e.order);

  factory SkillGroupModel.fromMap(
      Map<String, dynamic> map,
      ) {
    return SkillGroupModel(
      id: map['id'] as String? ?? '',
      category: map['category'] as String? ?? '',
      items: _strings(map['items']),
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'items': items,
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
