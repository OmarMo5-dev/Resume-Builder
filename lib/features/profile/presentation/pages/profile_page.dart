import 'package:business_os/features/profile/presentation/widgets/profile_from.dart';
import 'package:business_os/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/di/injection_container.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ProfileCubit>()..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _profileFormKey = GlobalKey<ProfileFromState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile",
        icon: Icons.person_2_outlined,
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final saving = state.status == ProfileStatus.saving;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade600.withValues(
                      alpha: 0.32,
                    ),
                  ),
                  onPressed: saving
                      ? null
                      : () => _profileFormKey.currentState?.save(),
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              );
            },
          ),
        ],
      ),
      body: ProfileFrom(key: _profileFormKey),
    );
  }
}
