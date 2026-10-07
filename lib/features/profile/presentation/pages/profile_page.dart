import 'package:business_os/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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

  // ============================================================
  //  Sign Out Flow
  // ============================================================
  Future<void> _confirmSignOut(BuildContext pageContext) async {
    final confirmed = await showDialog<bool>(
      context: pageContext,
      builder: (dialogContext) {
        final cs = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.logout_rounded, color: cs.error, size: 28),
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    if (!pageContext.mounted) return;

    // Capture messenger + router BEFORE the async gap
    final messenger = ScaffoldMessenger.of(pageContext);
    final router = GoRouter.of(pageContext);
    final authCubit = pageContext.read<AuthCubit>();

    await authCubit.signOut();

    if (!pageContext.mounted) return;

    // Show success snackbar
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Signed out successfully'),
        ),
      );

    // Navigate to login & clear the stack
    router.go('/auth/login');
  }

  // ============================================================
  //  Save Profile
  // ============================================================
  void _saveProfile(BuildContext context, ProfileState s) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<ProfileCubit>().save(
      displayName: _nameController.text.trim(),
    );
  }

  // ============================================================
  //  BUILD
  // ============================================================
  @override
  Widget build(BuildContext c) {
    final theme = Theme.of(c);
    final cs = theme.colorScheme;

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
        },
        builder: (c, s) {
          if (s.status == ProfileStatus.loading || s.profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = s.profile!;
          final initial = profile.displayName.trim().isEmpty
              ? '?'
              : profile.displayName.trim()[0].toUpperCase();
          final isSaving = s.status == ProfileStatus.saving;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                // ---------- Avatar ----------
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
                              cs.primary,
                              cs.primary.withOpacity(0.6),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initial,
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: cs.onPrimary,
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
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // ---------- Section: ACCOUNT ----------
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'ACCOUNT',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // ---------- Form Card ----------
                Card(
                  elevation: 0,
                  color: cs.surfaceContainerHighest.withOpacity(0.35),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: cs.outlineVariant.withOpacity(0.4),
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

                // ---------- Save Button ----------
                SizedBox(
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isSaving ? null : () => _saveProfile(c, s),
                    icon: isSaving
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
                      isSaving ? 'Saving…' : 'Save Changes',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // ---------- DANGER ZONE ----------
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    'DANGER ZONE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: cs.error,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Card(
                  elevation: 0,
                  color: cs.errorContainer.withOpacity(0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: BorderSide(
                      color: cs.error.withOpacity(0.35),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    leading: Icon(Icons.logout_rounded, color: cs.error),
                    title: Text(
                      'Sign Out',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.error,
                      ),
                    ),
                    subtitle: Text(
                      'You will be returned to the login screen',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    trailing: Icon(Icons.chevron_right_rounded, color: cs.error),
                    onTap: () => _confirmSignOut(c),
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