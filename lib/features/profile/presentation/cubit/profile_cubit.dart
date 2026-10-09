import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_profile.dart';
import '../../domain/usecases/update_profile.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetProfile getProfile;
  final UpdateProfile updateProfile;

  ProfileCubit({required this.getProfile, required this.updateProfile})
      : super(const ProfileState());

  Future<void> load() async {
    if (isClosed) return;
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    try {
      final profile = await getProfile();
      if (isClosed) return;
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(status: ProfileStatus.failure, error: _message(e)));
    }
  }

  Future<bool> save({
    required String displayName,
    required String phone,
    required String location,
    required String linkedinUrl,
    required String githubUrl,
    required String websiteUrl,
    required String defaultTemplateId,
    required String defaultResumeTitle,
  }) async {
    final current = state.profile;
    if (current == null || isClosed) return false;

    emit(state.copyWith(status: ProfileStatus.saving, clearError: true));

    final updated = current.copyWith(
      displayName: displayName.trim(),
      phone: phone.trim(),
      location: location.trim(),
      linkedinUrl: linkedinUrl.trim(),
      githubUrl: githubUrl.trim(),
      websiteUrl: websiteUrl.trim(),
      defaultTemplateId: defaultTemplateId,
      defaultResumeTitle: defaultResumeTitle.trim().isEmpty
          ? 'My Resume'
          : defaultResumeTitle.trim(),
    );

    try {
      final profile = await updateProfile(profile: updated);
      if (isClosed) return true;
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
          clearError: true,
        ),
      );
      return true;
    } catch (e) {
      if (isClosed) return false;
      emit(state.copyWith(status: ProfileStatus.failure, error: _message(e)));
      return false;
    }
  }

  String _message(Object error) {
    final value = error.toString();
    return value.startsWith('Exception: ')
        ? value.substring('Exception: '.length)
        : value;
  }
}
