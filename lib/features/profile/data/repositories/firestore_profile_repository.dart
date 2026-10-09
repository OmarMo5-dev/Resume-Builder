import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class FirestoreProfileRepository implements ProfileRepository {
  final ProfileRemoteDataSource source;
  FirestoreProfileRepository(this.source);

  @override
  Future<UserProfile> getProfile() => source.getProfile();

  @override
  Future<UserProfile> updateProfile({required UserProfile profile}) {
    return source.updateProfile(
      UserProfileModel(
        uid: profile.uid,
        displayName: profile.displayName,
        email: profile.email,
        phone: profile.phone,
        location: profile.location,
        linkedinUrl: profile.linkedinUrl,
        githubUrl: profile.githubUrl,
        websiteUrl: profile.websiteUrl,
        defaultTemplateId: profile.defaultTemplateId,
        defaultResumeTitle: profile.defaultResumeTitle,
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt,
      ),
    );
  }
}
