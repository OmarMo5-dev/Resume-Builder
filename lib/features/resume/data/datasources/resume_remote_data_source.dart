import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/resume_model.dart';

class ResumeRemoteDataSource {
  final FirebaseFirestore firestore;
  ResumeRemoteDataSource({required this.firestore});

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      firestore.collection('users').doc(uid).collection('resumes');

  Future<List<ResumeModel>> getResumes(String uid) async {
    final snapshot = await _col(uid).orderBy('updatedAt', descending: true).get();
    return snapshot.docs.map(ResumeModel.fromFirestore).toList();
  }

  Future<ResumeModel> getResume(String uid, String id) async {
    final doc = await _col(uid).doc(id).get();
    if (!doc.exists) throw Exception('Resume not found.');
    return ResumeModel.fromFirestore(doc);
  }

  Future<ResumeModel> getPublicResume(String uid, String id) async {
    final doc = await _col(uid).doc(id).get();
    if (!doc.exists) throw Exception('Resume not found.');
    final resume = ResumeModel.fromFirestore(doc);
    if (!resume.isPublic) throw Exception('This resume is private.');
    return resume;
  }

  Future<ResumeModel> createResume(String uid, ResumeModel resume) async {
    final ref = _col(uid).doc();
    await ref.set(resume.toFirestore());
    return ResumeModel.fromFirestore(await ref.get());
  }

  Future<ResumeModel> updateResume(String uid, ResumeModel resume) async {
    final ref = _col(uid).doc(resume.id);
    await ref.update(resume.toFirestore(includeCreatedAt: false));
    return ResumeModel.fromFirestore(await ref.get());
  }

  Future<void> deleteResume(String uid, String id) => _col(uid).doc(id).delete();
}
