import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/personal_info.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/resume.dart';
import '../../domain/entities/skill_group.dart';
import '../../domain/usecases/create_resume.dart';
import '../../domain/usecases/update_resume.dart';
import 'resume_editor_state.dart';

enum SaveOutcome { saved, nothingToSave, failed }

class ResumeEditorCubit extends Cubit<ResumeEditorState> {
  final CreateResume _create;
  final UpdateResume _update;

  /// The resume exactly as the editor opened it (including any pre-filled
  /// profile data). Used to decide whether the user typed anything.
  final Resume _baseline;

  ResumeEditorCubit({
    required CreateResume create,
    required UpdateResume update,
    required Resume resume,
  })  : _create = create,
        _update = update,
        _baseline = resume,
        super(ResumeEditorState(resume: resume));

  /// Existing (already persisted) resumes are always saveable; new ones only
  /// once the user has entered something beyond the pre-filled defaults.
  bool get canPersist {
    final r = state.resume;
    return r.id.isEmpty
        ? r.hasMeaningfulContent(baseline: _baseline)
        : r.hasMeaningfulContent();
  }

  void _set(Resume resume) => emit(
        state.copyWith(resume: resume, dirty: true, status: EditorStatus.initial, clearError: true),
      );

  void setTitle(String value) => _set(state.resume.copyWith(title: value));
  void setTemplate(String value) => _set(state.resume.copyWith(templateId: value));
  void setPublic(bool value) => _set(state.resume.copyWith(isPublic: value));
  void setSummary(String value) => _set(state.resume.copyWith(summary: value));
  void setPersonalInfo(PersonalInfo value) => _set(state.resume.copyWith(personalInfo: value));
  void setEducation(List<Education> value) => _set(state.resume.copyWith(education: value));
  void setExperience(List<Experience> value) => _set(state.resume.copyWith(experience: value));
  void setCourses(List<Course> value) => _set(state.resume.copyWith(courses: value));
  void setProjects(List<Project> value) => _set(state.resume.copyWith(projects: value));
  void setSkills(List<SkillGroup> value) => _set(state.resume.copyWith(skills: value));
  void setLanguages(List<Language> value) => _set(state.resume.copyWith(languages: value));

  Future<SaveOutcome> saveDraft() => _save(isDraft: true);

  Future<SaveOutcome> completeResume() => _save(isDraft: false);

  Future<SaveOutcome> _save({required bool isDraft}) async {
    if (state.status == EditorStatus.saving) return SaveOutcome.nothingToSave;
    if (!canPersist) return SaveOutcome.nothingToSave;

    emit(state.copyWith(status: EditorStatus.saving, clearError: true));
    try {
      final toSave = state.resume.copyWith(updatedAt: DateTime.now(), isDraft: isDraft);
      // New resumes (empty id) are created exactly once; afterwards the
      // returned document carries its Firestore id so every later save updates.
      final saved = toSave.id.isEmpty
          ? await _create(resume: toSave)
          : await _update(resume: toSave);
      emit(state.copyWith(resume: saved, status: EditorStatus.saved, dirty: false));
      return SaveOutcome.saved;
    } catch (e, st) {
      debugPrint('Saving resume failed: $e\n$st');
      emit(state.copyWith(status: EditorStatus.failure, error: e.toString()));
      return SaveOutcome.failed;
    }
  }
}
