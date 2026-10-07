import '../entities/resume.dart';
import '../repositories/resume_repository.dart';

class DuplicateResume {
  final ResumeRepository repository;
  DuplicateResume(this.repository);

  /// Creates a separate copy (new Firestore id, private, same draft state).
  Future<Resume> call({required Resume resume}) {
    final now = DateTime.now();
    return repository.createResume(
      resume: resume.copyWith(
        id: '',
        title: '${resume.title} Copy',
        createdAt: now,
        updatedAt: now,
        isPublic: false,
      ),
    );
  }
}
