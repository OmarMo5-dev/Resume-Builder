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
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: await getProfile(),
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
    }
  }

  Future<bool> save({required String displayName}) async {
    if (state.profile == null) return false;
    emit(state.copyWith(status: ProfileStatus.saving));
    try {
      final p = await updateProfile(
        profile: state.profile!.copyWith(displayName: displayName.trim()),
      );
      emit(state.copyWith(status: ProfileStatus.success, profile: p));
      return true;
    } catch (e) {
      emit(state.copyWith(status: ProfileStatus.failure, error: e.toString()));
      return false;
    }
  }
}
