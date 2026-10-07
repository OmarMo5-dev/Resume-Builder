import 'course.dart';
import 'education.dart';
import 'experience.dart';
import 'language.dart';
import 'personal_info.dart';
import 'project.dart';
import 'skill_group.dart';

class Resume {
  final String id;
  final String title;
  final String templateId;
  final bool isDraft;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PersonalInfo personalInfo;
  final String summary;
  final List<Education> education;
  final List<Experience> experience;
  final List<Course> courses;
  final List<Project> projects;
  final List<SkillGroup> skills;
  final List<Language> languages;

  const Resume({
    required this.id,
    required this.title,
    required this.templateId,
    required this.isDraft,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.personalInfo,
    required this.summary,
    required this.education,
    required this.experience,
    required this.courses,
    required this.projects,
    required this.skills,
    required this.languages,
  });

  Resume copyWith({
    String? id,
    String? title,
    String? templateId,
    bool? isDraft,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    PersonalInfo? personalInfo,
    String? summary,
    List<Education>? education,
    List<Experience>? experience,
    List<Course>? courses,
    List<Project>? projects,
    List<SkillGroup>? skills,
    List<Language>? languages,
  }) => Resume(
        id: id ?? this.id,
        title: title ?? this.title,
        templateId: templateId ?? this.templateId,
        isDraft: isDraft ?? this.isDraft,
        isPublic: isPublic ?? this.isPublic,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        personalInfo: personalInfo ?? this.personalInfo,
        summary: summary ?? this.summary,
        education: education ?? this.education,
        experience: experience ?? this.experience,
        courses: courses ?? this.courses,
        projects: projects ?? this.projects,
        skills: skills ?? this.skills,
        languages: languages ?? this.languages,
      );

  /// True when the resume holds something the user actually typed.
  ///
  /// Title, template, timestamps, flags and empty collections are defaults and
  /// never count. When [baseline] is given (the pre-filled resume a new editor
  /// session starts from) personal fields that still equal the baseline do not
  /// count either, so a resume containing only the auto-filled name/email is
  /// not considered meaningful.
  bool hasMeaningfulContent({Resume? baseline}) {
    final p = personalInfo;
    final b = baseline?.personalInfo;

    bool changed(String? value, String? original) {
      final v = (value ?? '').trim();
      if (v.isEmpty) return false;
      return v != (original ?? '').trim();
    }

    if (changed(p.fullName, b?.fullName) ||
        changed(p.jobTitle, b?.jobTitle) ||
        changed(p.email, b?.email) ||
        changed(p.phone, b?.phone) ||
        changed(p.location, b?.location) ||
        changed(p.linkedin, b?.linkedin) ||
        changed(p.github, b?.github) ||
        changed(p.website, b?.website) ||
        summary.trim().isNotEmpty) {
      return true;
    }

    for (final e in education) {
      if (e.degree.trim().isNotEmpty || e.institution.trim().isNotEmpty) return true;
    }
    for (final e in experience) {
      if (e.position.trim().isNotEmpty || e.company.trim().isNotEmpty) return true;
    }
    for (final e in courses) {
      if (e.name.trim().isNotEmpty || e.provider.trim().isNotEmpty) return true;
    }
    for (final e in projects) {
      if (e.name.trim().isNotEmpty) return true;
    }
    for (final e in skills) {
      if (e.category.trim().isNotEmpty) return true;
      for (final item in e.items) {
        if (item.trim().isNotEmpty) return true;
      }
    }
    for (final e in languages) {
      if (e.name.trim().isNotEmpty) return true;
    }
    return false;
  }
}
