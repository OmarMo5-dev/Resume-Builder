import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/resume.dart';
import '../../domain/repositories/resume_repository.dart';
import '../datasources/resume_remote_data_source.dart';
import '../models/resume_model.dart';

class FirestoreResumeRepository implements ResumeRepository {
  final ResumeRemoteDataSource remoteDataSource;
  final FirebaseAuth firebaseAuth;

  FirestoreResumeRepository({
    required this.remoteDataSource,
    required this.firebaseAuth,
  });

  String get uid => firebaseAuth.currentUser?.uid ?? (throw Exception('User is not authenticated.'));

  @override
  Future<List<Resume>> getResumes() => remoteDataSource.getResumes(uid);

  @override
  Future<Resume> getResume(String id) => remoteDataSource.getResume(uid, id);

  @override
  Future<Resume> getPublicResume(String userId, String id) => remoteDataSource.getPublicResume(userId, id);

  @override
  Future<Resume> createResume({required Resume resume}) =>
      remoteDataSource.createResume(uid, ResumeModel.fromEntity(resume));

  @override
  Future<Resume> updateResume({required Resume resume}) =>
      remoteDataSource.updateResume(uid, ResumeModel.fromEntity(resume));

  @override
  Future<void> deleteResume({required String resumeId}) => remoteDataSource.deleteResume(uid, resumeId);
}
