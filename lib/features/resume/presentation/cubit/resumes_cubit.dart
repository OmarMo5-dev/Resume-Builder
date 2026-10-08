import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/personal_info.dart';
import '../../domain/entities/resume.dart';
import '../../domain/usecases/create_resume.dart';
import '../../domain/usecases/delete_resume.dart';
import '../../domain/usecases/duplicate_resume.dart';
import '../../domain/usecases/get_resumes.dart';
import '../../domain/usecases/update_resume.dart';
import 'resumes_state.dart';

class ResumesCubit extends Cubit<ResumesState> {
  final GetResumes getResumes;
  final CreateResume createResume;      // field (usecase)
  final UpdateResume updateResume;      // field (usecase)
  final DeleteResume deleteResume;      // field (usecase)
  final DuplicateResume duplicateResume;
  final FirebaseAuth auth;

  ResumesCubit({
    required this.getResumes,
    required this.createResume,
    required this.updateResume,
    required this.deleteResume,
    required this.duplicateResume,
    required this.auth,
  }) : super(const ResumesState());

  Future<void> loadResumes() async {
    if (isClosed) return;
    emit(state.copyWith(status: ResumesStatus.loading, clearError: true));
    try {
      final resumes = await getResumes();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ResumesStatus.success,
          resumes: resumes,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ResumesStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<Resume?> createNewResume() async {

    try {
      final user = auth.currentUser;
      final now = DateTime.now();
      final r = Resume(
        id: '',
        title: 'My Resume',
        templateId: 'classic_01',
        isDraft: true,
        isPublic: false,
        createdAt: now,
        updatedAt: now,
        personalInfo: PersonalInfo(
          fullName: user?.displayName ?? '',
          jobTitle: '',
          email: user?.email ?? '',
          phone: '',
          location: '',
        ),
        summary: '',
        education: const [],
        experience: const [],
        courses: const [],
        projects: const [],
        skills: const [],
        languages: const [],
      );
      return r;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), action: ResumeAction.none));
      return null;
    }
  }

  Future<bool> updateResumeData(Resume r) async {
    emit(state.copyWith(action: ResumeAction.updating, clearError: true));
    try {
      final x = await updateResume(
        resume: r.copyWith(updatedAt: DateTime.now()),
      );
      emit(
        state.copyWith(
          status: ResumesStatus.success,
          resumes: state.resumes.map((e) => e.id == x.id ? x : e).toList(),
          action: ResumeAction.none,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), action: ResumeAction.none),
      );
      return false;
    }
  }

  Future<bool> deleteResumeById(String id) async {
    emit(state.copyWith(action: ResumeAction.deleting, clearError: true));
    try {
      await deleteResume(resumeId: id);
      emit(
        state.copyWith(
          status: ResumesStatus.success,
          resumes: state.resumes.where((e) => e.id != id).toList(),
          action: ResumeAction.none,
        ),
      );
      return true;
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), action: ResumeAction.none),
      );
      return false;
    }
  }

  Future<Resume?> duplicateResumeData(Resume r) async {
    emit(state.copyWith(action: ResumeAction.duplicating, clearError: true));
    try {
      final x = await duplicateResume(resume: r);
      emit(
        state.copyWith(
          status: ResumesStatus.success,
          resumes: [x, ...state.resumes],
          action: ResumeAction.none,
        ),
      );
      return x;
    } catch (e) {
      emit(
        state.copyWith(errorMessage: e.toString(), action: ResumeAction.none),
      );
      return null;
    }
  }
}
