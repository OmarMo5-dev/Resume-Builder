import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/di/injection_container.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext c) => BlocProvider(
    create: (_) => getIt<ProfileCubit>()..load(),
    child: const _View(),
  );
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _S();
}

class _S extends State<_View> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _nameInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (c, s) {
          if (s.error != null) {
            ScaffoldMessenger.of(c).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(s.error!),
              ),
            );
          }
          if (s.status == ProfileStatus.success &&
              s.profile != null &&
              !_nameInitialized) {
            _nameController.text = s.profile!.displayName;
            _nameInitialized = true;
          }
          if (s.status == ProfileStatus.saving) {
            ScaffoldMessenger.of(c).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Profile saved'),
              ),
            );
          }
        },
        builder: (c, s) {
          if (s.status == ProfileStatus.loading || s.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = s.profile!;
          final initial = profile.displayName.trim().isEmpty
              ? '?'
              : profile.displayName.trim()[0].toUpperCase();

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // Avatar
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        profile.displayName.isEmpty
                            ? 'Your Name'
                            : profile.displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Section title
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'ACCOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Form card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest
                      .withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant
                          .withOpacity(0.4),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Display name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            if (v.trim().length < 2) {
                              return 'Name is too short';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          initialValue: profile.email,
                          enabled: false,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.mail_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: s.status == ProfileStatus.saving
                        ? null
                        : () {
                      if (_formKey.currentState?.validate() ?? false) {
                        c.read<ProfileCubit>().save(
                          displayName: _nameController.text.trim(),
                        );
                      }
                    },
                    icon: s.status == ProfileStatus.saving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.check_rounded),
                    label: Text(
                      s.status == ProfileStatus.saving
                          ? 'Saving…'
                          : 'Save Changes',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}