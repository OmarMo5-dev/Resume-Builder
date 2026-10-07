import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/resume.dart';
import 'course_model.dart';
import 'education_model.dart';
import 'experience_model.dart';
import 'language_model.dart';
import 'personal_info_model.dart';
import 'project_model.dart';
import 'skill_group_model.dart';

class ResumeModel extends Resume {
  const ResumeModel({
    required super.id, required super.title, required super.templateId,
    required super.isDraft, required super.isPublic, required super.createdAt,
    required super.updatedAt, required super.personalInfo, required super.summary,
    required super.education, required super.experience, required super.courses,
    required super.projects, required super.skills, required super.languages,
  });

  factory ResumeModel.fromEntity(Resume r) => ResumeModel(
    id: r.id, title: r.title, templateId: r.templateId, isDraft: r.isDraft,
    isPublic: r.isPublic, createdAt: r.createdAt, updatedAt: r.updatedAt,
    personalInfo: PersonalInfoModel.fromEntity(r.personalInfo), summary: r.summary,
    education: r.education.map(EducationModel.fromEntity).toList(),
    experience: r.experience.map(ExperienceModel.fromEntity).toList(),
    courses: r.courses.map(CourseModel.fromEntity).toList(),
    projects: r.projects.map(ProjectModel.fromEntity).toList(),
    skills: r.skills.map(SkillGroupModel.fromEntity).toList(),
    languages: r.languages.map(LanguageModel.fromEntity).toList(),
  );

  factory ResumeModel.fromFirestore(DocumentSnapshot<Map<String,dynamic>> doc) {
    final d=doc.data()??{};
    return ResumeModel(
      id: doc.id, title: d['title'] as String? ?? '',
      templateId: d['templateId'] as String? ?? 'classic_01',
      isDraft: d['isDraft'] as bool? ?? true, isPublic: d['isPublic'] as bool? ?? false,
      createdAt: _date(d['createdAt']), updatedAt: _date(d['updatedAt']),
      personalInfo: PersonalInfoModel.fromMap(_map(d['personalInfo'])),
      summary: d['summary'] as String? ?? '',
      education: _list(d['education']).map(EducationModel.fromMap).toList(),
      experience: _list(d['experience']).map(ExperienceModel.fromMap).toList(),
      courses: _list(d['courses']).map(CourseModel.fromMap).toList(),
      projects: _list(d['projects']).map(ProjectModel.fromMap).toList(),
      skills: _list(d['skills']).map(SkillGroupModel.fromMap).toList(),
      languages: _list(d['languages']).map(LanguageModel.fromMap).toList(),
    );
  }

  /// [includeCreatedAt] is false for updates so the original creation time
  /// stored in Firestore is never overwritten.
  Map<String, dynamic> toFirestore({bool includeCreatedAt = true}) => {
        'title': title,
        'templateId': templateId,
        'isDraft': isDraft,
        'isPublic': isPublic,
        if (includeCreatedAt) 'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'personalInfo': PersonalInfoModel.fromEntity(personalInfo).toMap(),
        'summary': summary,
        'education': [for (final e in education) EducationModel.fromEntity(e).toMap()],
        'experience': [for (final e in experience) ExperienceModel.fromEntity(e).toMap()],
        'courses': [for (final e in courses) CourseModel.fromEntity(e).toMap()],
        'projects': [for (final e in projects) ProjectModel.fromEntity(e).toMap()],
        'skills': [for (final e in skills) SkillGroupModel.fromEntity(e).toMap()],
        'languages': [for (final e in languages) LanguageModel.fromEntity(e).toMap()],
      };

  static DateTime _date(dynamic v) => v is Timestamp ? v.toDate() : DateTime.now();
  static Map<String,dynamic> _map(dynamic v) => v is Map ? Map<String,dynamic>.from(v) : {};
  static List<Map<String,dynamic>> _list(dynamic v) => v is List ? [for (final e in v) if (e is Map) Map<String, dynamic>.from(e)] : <Map<String, dynamic>>[];
}
