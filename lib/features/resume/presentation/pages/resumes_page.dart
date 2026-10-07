import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/resume.dart';
import '../../services/resume_pdf_service.dart';
import '../cubit/resumes_cubit.dart';
import '../cubit/resumes_state.dart';
import '../widgets/empty_resumes.dart';
import '../widgets/entry_dialog.dart';
import '../widgets/resume_card.dart';
import '../widgets/resume_loading.dart';

class ResumesPage extends StatelessWidget {
  const ResumesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resumes'),
        titleTextStyle: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => context.push('/profile'),
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 4),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Create Resume'),
        elevation: 4,
      ),
      body: BlocConsumer<ResumesCubit, ResumesState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.action == ResumeAction.none) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text(state.errorMessage!),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ResumesStatus.initial ||
              state.status == ResumesStatus.loading) {
            return const ResumeLoading();
          }
          if (state.status == ResumesStatus.failure) {
            return _Error(
              onRetry: () => context.read<ResumesCubit>().loadResumes(),
              message: state.errorMessage,
            );
          }
          if (state.resumes.isEmpty) {
            return EmptyResumes(onCreate: () => _create(context));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<ResumesCubit>().loadResumes(),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: state.resumes.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${state.resumes.length} ${state.resumes.length == 1 ? 'resume' : 'resumes'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }
                final resume = state.resumes[index - 1];
                return ResumeCard(
                  resume: resume,
                  onTap: () => context.push('/resumes/editor', extra: resume),
                  onPreview: () =>
                      context.push('/resumes/preview', extra: resume),
                  onShare: () => _share(context, resume),
                  onRename: () => _rename(context, resume),
                  onDuplicate: () async {
                    final copy = await context
                        .read<ResumesCubit>()
                        .duplicateResumeData(resume);
                    if (copy != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          behavior: SnackBarBehavior.floating,
                          content: Text('Resume duplicated'),
                        ),
                      );
                    }
                  },
                  onDelete: () => _delete(context, resume),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _create(BuildContext context) async {
    final resume = await context.read<ResumesCubit>().createNewResume();
    if (resume == null || !context.mounted) return;
    await context.push('/resumes/editor', extra: resume);
    if (context.mounted) await context.read<ResumesCubit>().loadResumes();
  }

  Future<void> _share(BuildContext context, Resume resume) async {
    try {
      await ResumePdfService.share(resume);
    } on ResumePdfException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(e.message),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('Unexpected share error: $e\n$st');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('PDF sharing failed: $e'),
          ),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, Resume resume) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Resume?'),
        content: Text('Delete "${resume.title}" permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<ResumesCubit>().deleteResumeById(resume.id);
    }
  }

  Future<void> _rename(BuildContext context, Resume resume) async {
    final result = await showEntryDialog(
      context,
      title: 'Rename Resume',
      fields: [
        EntryField(
          'title',
          'Resume title',
          initial: resume.title,
          capitalization: TextCapitalization.words,
        ),
      ],
    );
    if (result == null || !context.mounted) return;
    final title = result['title'].trim();
    if (title.isEmpty) return;
    await context
        .read<ResumesCubit>()
        .updateResumeData(resume.copyWith(title: title));
  }
}

class _Error extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  const _Error({required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Oops!',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}