import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/di/injection_container.dart';
import '../../domain/entities/personal_info.dart';
import '../../domain/entities/resume.dart';
import '../../domain/usecases/create_resume.dart';
import '../../domain/usecases/update_resume.dart';
import '../../services/resume_pdf_service.dart';
import '../cubit/resume_editor_cubit.dart';
import '../cubit/resume_editor_state.dart';
import '../widgets/editor_bottom_bar.dart';
import '../widgets/editor_hero.dart';
import '../widgets/editor_progress_header.dart';
import '../widgets/resume_editor_step_content.dart';

class ResumeEditorPage extends StatelessWidget {
  final Resume resume;

  const ResumeEditorPage({super.key, required this.resume});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ResumeEditorCubit(
        create: getIt<CreateResume>(),
        update: getIt<UpdateResume>(),
        resume: resume,
      ),
      child: _ResumeEditorView(initial: resume),
    );
  }
}

class _ResumeEditorView extends StatefulWidget {
  final Resume initial;

  const _ResumeEditorView({required this.initial});

  @override
  State<_ResumeEditorView> createState() => _ResumeEditorViewState();
}

class _ResumeEditorViewState extends State<_ResumeEditorView> {
  late final TextEditingController _title;
  late final TextEditingController _name;
  late final TextEditingController _job;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _location;
  late final TextEditingController _linkedin;
  late final TextEditingController _github;
  late final TextEditingController _website;
  late final TextEditingController _summary;

  bool _pdfBusy = false;
  int _currentStep = 0;

  static const steps = <EditorStepInfo>[
    EditorStepInfo(label: 'Basics', icon: Icons.tune_rounded),
    EditorStepInfo(label: 'Personal', icon: Icons.person_outline_rounded),
    EditorStepInfo(label: 'Summary', icon: Icons.notes_rounded),
    EditorStepInfo(label: 'Experience', icon: Icons.work_outline_rounded),
    EditorStepInfo(label: 'Education', icon: Icons.school_outlined),
    EditorStepInfo(label: 'Projects', icon: Icons.folder_outlined),
    EditorStepInfo(label: 'Skills', icon: Icons.auto_awesome_outlined),
    EditorStepInfo(label: 'More', icon: Icons.add_circle_outline_rounded),
    EditorStepInfo(label: 'Finish', icon: Icons.check_circle_outline_rounded),
  ];

  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    final p = r.personalInfo;

    _title = TextEditingController(text: r.title);
    _name = TextEditingController(text: p.fullName);
    _job = TextEditingController(text: p.jobTitle);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
    _location = TextEditingController(text: p.location);
    _linkedin = TextEditingController(text: p.linkedin ?? '');
    _github = TextEditingController(text: p.github ?? '');
    _website = TextEditingController(text: p.website ?? '');
    _summary = TextEditingController(text: r.summary);
  }

  @override
  void dispose() {
    for (final controller in [
      _title,
      _name,
      _job,
      _email,
      _phone,
      _location,
      _linkedin,
      _github,
      _website,
      _summary,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  ResumeEditorCubit get cubit => context.read<ResumeEditorCubit>();

  void _pushPersonal() {
    cubit.setPersonalInfo(
      PersonalInfo(
        fullName: _name.text.trim(),
        jobTitle: _job.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        location: _location.text.trim(),
        linkedin: _nullIfBlank(_linkedin.text),
        github: _nullIfBlank(_github.text),
        website: _nullIfBlank(_website.text),
      ),
    );
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? cs.error : null,
          content: Text(message),
        ),
      );
  }

  Future<void> _save({required bool complete}) async {
    final outcome = complete
        ? await cubit.completeResume()
        : await cubit.saveDraft();

    if (!mounted) return;

    switch (outcome) {
      case SaveOutcome.saved:
        _toast(complete ? '🎉 Resume completed!' : 'Draft saved');
        if (complete && context.canPop()) context.pop();
      case SaveOutcome.nothingToSave:
        _toast('Add some resume content first', error: true);
      case SaveOutcome.failed:
        _toast(
          'Could not save: ${cubit.state.error ?? 'unknown error'}',
          error: true,
        );
    }
  }

  Future<void> _pdf(Future<void> Function(Resume) action) async {
    if (_pdfBusy) return;

    setState(() => _pdfBusy = true);
    try {
      await action(cubit.state.resume);
    } on ResumePdfException catch (e) {
      _toast(e.message, error: true);
    } catch (e, st) {
      debugPrint('Unexpected PDF error: $e\n$st');
      _toast('PDF generation failed', error: true);
    } finally {
      if (mounted) setState(() => _pdfBusy = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes that will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return discard == true;
  }

  void _nextStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_currentStep < steps.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _goToStep(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (index != _currentStep) {
      setState(() => _currentStep = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, shell) {
        final isSaving = shell.status == EditorStatus.saving;

        final keyboardIsOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;

            final unsaved = cubit.state.dirty && cubit.canPersist;
            if (unsaved && !await _confirmDiscard()) return;

            if (mounted && context.mounted && context.canPop()) {
              context.pop();
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            backgroundColor: cs.surface,
            appBar: AppBar(
              scrolledUnderElevation: 0,
              titleSpacing: 0,
              title: const Text('Resume Editor'),
              actions: [
                IconButton(
                  tooltip: 'Preview',
                  icon: const Icon(Icons.visibility_outlined),
                  onPressed: () => context.push(
                    '/resumes/preview',
                    extra: cubit.state.resume,
                  ),
                ),
                IconButton(
                  tooltip: 'Export PDF',
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: _pdfBusy
                      ? null
                      : () => _pdf(ResumePdfService.export),
                ),
                IconButton(
                  tooltip: 'Share PDF',
                  icon: const Icon(Icons.ios_share_outlined),
                  onPressed: _pdfBusy
                      ? null
                      : () => _pdf(ResumePdfService.share),
                ),
                const SizedBox(width: 6),
              ],
            ),
            body: Column(
              children: [
                EditorProgressHeader(
                  steps: steps,
                  currentIndex: _currentStep,
                  onStepTap: _goToStep,
                ),
                BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
                  builder: (context, state) {
                    if (_currentStep != 0) {
                      return const SizedBox.shrink();
                    }

                    return EditorHero(resume: state.resume, dirty: state.dirty);
                  },
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final offset = Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation);

                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: offset, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(_currentStep),
                      child: ResumeEditorStepContent(
                        step: _currentStep,
                        onPreview: () => context.push(
                          '/resumes/preview',
                          extra: cubit.state.resume,
                        ),
                        onExport: () => _pdf(ResumePdfService.export),
                        onShare: () => _pdf(ResumePdfService.share),
                        onComplete: () => _save(complete: true),
                        titleController: _title,
                        nameController: _name,
                        jobController: _job,
                        emailController: _email,
                        phoneController: _phone,
                        locationController: _location,
                        linkedinController: _linkedin,
                        githubController: _github,
                        websiteController: _website,
                        summaryController: _summary,
                        onPersonalChanged: _pushPersonal,
                      ),
                    ),
                  ),
                ),
                if (!keyboardIsOpen)
                  EditorBottomBar(
                    currentIndex: _currentStep,
                    totalSteps: steps.length,
                    isSaving: isSaving,
                    onBack: _prevStep,
                    onNext: _nextStep,
                    onSaveDraft: () => _save(complete: false),
                    onComplete: () => _save(complete: true),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String? _nullIfBlank(String value) =>
      value.trim().isEmpty ? null : value.trim();
}
