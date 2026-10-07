import '../entities/resume.dart';
abstract class ResumeRepository {
  Future<List<Resume>> getResumes();
  Future<Resume> getResume(String resumeId);
  Future<Resume> getPublicResume(String uid, String resumeId);
  Future<Resume> createResume({required Resume resume});
  Future<Resume> updateResume({required Resume resume});
  Future<void> deleteResume({required String resumeId});
}
