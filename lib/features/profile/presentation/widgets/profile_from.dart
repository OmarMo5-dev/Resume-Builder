import 'package:business_os/features/profile/presentation/widgets/profile_header.dart';
import 'package:business_os/features/resume/presentation/widgets/resume_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileFrom extends StatefulWidget {
  const ProfileFrom({super.key});

  @override
  State<ProfileFrom> createState() => ProfileFromState();
}

class ProfileFromState extends State<ProfileFrom> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _websiteController = TextEditingController();
  final _resumeTitleController = TextEditingController();

  String _templateId = 'classic_01';
  bool _hydrated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _websiteController.dispose();
    _resumeTitleController.dispose();
    super.dispose();
  }

  void _hydrate(UserProfile profile) {
    if (_hydrated) return;
    _nameController.text = profile.displayName;
    _phoneController.text = profile.phone;
    _locationController.text = profile.location;
    _linkedinController.text = profile.linkedinUrl;
    _githubController.text = profile.githubUrl;
    _websiteController.text = profile.websiteUrl;
    _resumeTitleController.text = profile.defaultResumeTitle;
    _templateId = profile.defaultTemplateId;
    _hydrated = true;
  }

  Future<void> save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await context.read<ProfileCubit>().save(
      displayName: _nameController.text,
      phone: _phoneController.text,
      location: _locationController.text,
      linkedinUrl: _linkedinController.text,
      githubUrl: _githubController.text,
      websiteUrl: _websiteController.text,
      defaultTemplateId: _templateId,
      defaultResumeTitle: _resumeTitleController.text,
    );

    if (!mounted || !success) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Profile updated successfully'),
        ),
      );
  }

  Future<void> _confirmSignOut() async {
    final authCubit = context.read<AuthCubit>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final colors = Theme.of(dialogContext).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.logout_rounded, color: colors.error, size: 28),
          title: const Text('Sign Out'),
          content: const Text(
            'Are you sure you want to sign out of your account?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colors.error,
                foregroundColor: colors.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;
    await authCubit.signOut();
  }

  String? _urlValidator(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
    if (uri == null || uri.host.isEmpty) return 'Enter a valid $label URL';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state.profile != null) _hydrate(state.profile!);
        if (state.error != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(state.error!),
              ),
            );
        }
      },
      builder: (context, state) {
        if (state.status == ProfileStatus.loading || state.profile == null) {
          final authState = context.watch<AuthCubit>().state;
          if (authState.status == AuthStatus.unauthenticated) {
            return const SizedBox.shrink();
          }
          return const ResumeLoading();
        }

        final profile = state.profile!;
        _hydrate(profile);
        final saving = state.status == ProfileStatus.saving;
        final initial = profile.displayName.trim().isEmpty
            ? '?'
            : profile.displayName.trim().characters.first.toUpperCase();

        return Form(
          key: _formKey,
          child: ListView(
            physics: BouncingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              ProfileHeader(initial: initial, profile: profile, colors: colors),
              const SizedBox(height: 28),
              _SectionLabel(title: 'PERSONAL INFORMATION'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  _field(
                    controller: _nameController,
                    label: 'Full name',
                    icon: Icons.person_outline_rounded,
                    action: TextInputAction.next,
                    capitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      if (value.trim().length < 2) return 'Name is too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: profile.email,
                    enabled: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.mail_outline_rounded),
                      helperText: 'Email is managed by your account provider.',
                    ),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _phoneController,
                    label: 'Phone',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _locationController,
                    label: 'Location',
                    icon: Icons.location_on_outlined,
                    action: TextInputAction.next,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionLabel(title: 'PROFESSIONAL LINKS'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  _field(
                    controller: _linkedinController,
                    label: 'LinkedIn URL',
                    hint: 'https://linkedin.com/in/username',
                    icon: Icons.business_center_outlined,
                    keyboardType: TextInputType.url,
                    action: TextInputAction.next,
                    validator: (v) => _urlValidator(v, 'LinkedIn'),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _githubController,
                    label: 'GitHub URL',
                    hint: 'https://github.com/username',
                    icon: Icons.code_rounded,
                    keyboardType: TextInputType.url,
                    action: TextInputAction.next,
                    validator: (v) => _urlValidator(v, 'GitHub'),
                  ),
                  const SizedBox(height: 14),
                  _field(
                    controller: _websiteController,
                    label: 'Personal website',
                    hint: 'https://example.com',
                    icon: Icons.language_rounded,
                    keyboardType: TextInputType.url,
                    action: TextInputAction.done,
                    validator: (v) => _urlValidator(v, 'website'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SectionLabel(title: 'RESUME DEFAULTS'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  _field(
                    controller: _resumeTitleController,
                    label: 'Default resume title',
                    hint: 'My Resume',
                    icon: Icons.description_outlined,
                    action: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _templateId,
                    decoration: const InputDecoration(
                      labelText: 'Default template',
                      prefixIcon: Icon(Icons.auto_awesome_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'classic_01',
                        child: Text('Classic'),
                      ),
                      DropdownMenuItem(
                        value: 'modern_01',
                        child: Text('Modern'),
                      ),
                      DropdownMenuItem(
                        value: 'minimal_01',
                        child: Text('Minimal'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _templateId = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 28),
              _SectionLabel(title: 'SESSION'),
              const SizedBox(height: 8),
              _SectionCard(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.logout_rounded, color: colors.error),
                    title: Text(
                      'Sign out',
                      style: TextStyle(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    subtitle: const Text('Return to the login screen.'),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colors.error,
                    ),
                    onTap: saving ? null : _confirmSignOut,
                  ),
                ],
              ),
              const SizedBox(height: 70),
            ],
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: colors.onSurfaceVariant,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = (isDark ? cs.surfaceContainerHigh : Colors.white);

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}

TextFormField _field({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  required TextInputAction action,
  TextInputType? keyboardType,
  TextCapitalization capitalization = TextCapitalization.none,
  String? hint,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
    controller: controller,
    textInputAction: action,
    keyboardType: keyboardType,
    textCapitalization: capitalization,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
    ),
  );
}
