import '../entities/resume.dart';
import '../repositories/resume_repository.dart';

class CreateResume {
  final ResumeRepository repository;
  CreateResume(this.repository);

  Future<Resume> call({required Resume resume}) => repository.createResume(resume: resume);
}
