import 'package:business_os/shared/widgets/custom_app_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../domain/entities/resume.dart';
import '../../services/resume_pdf_service.dart';
import '../cubit/resumes_cubit.dart';
import '../cubit/resumes_state.dart';
import '../widgets/dashboard_widgets.dart';
import '../widgets/empty_dashboard.dart';
import '../widgets/entry_dialog.dart';
import '../widgets/resume_card.dart';
import '../widgets/resume_loading.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Dashboard", icon: Icons.dashboard_customize_outlined ,
      actions: [
        GestureDetector(
          onTap: ()=> context.read<ResumesCubit>().loadResumes(),
          child: Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 13),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(Icons.refresh_outlined, color: Colors.white, size: 18),
          ),
        ),
      ],

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
            return ErrorView(
              onRetry: () => context.read<ResumesCubit>().loadResumes(),
              message: state.errorMessage,
            );
          }

          final resumes = [...state.resumes]
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          final latest = resumes.isEmpty ? null : resumes.first;
          final user = FirebaseAuth.instance.currentUser;

          return LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth >= 1100 ? 1080.0 : 760.0;
              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 13),
                          DashboardWelcome(
                            name: user?.displayName ?? user?.email,
                            onCreate: () => _create(context),
                          ),
                          const SizedBox(height: 16),
                          const SizedBox(height: 16),
                          DashboardStats(resumes: resumes),
                          const SizedBox(height: 28),
                          DashboardSectionHeader(
                            title: 'Recent  Resumes ',
                            actionLabel: resumes.length > 3
                                ? 'View all'
                                : (resumes.any((r) => r.isPublic)
                                      ? 'Public'
                                      : null),
                            onAction: resumes.length > 3
                                ? () => _showAllResumes(context, resumes)
                                : (resumes.any((r) => r.isPublic)
                                      ? () => _openPublicResume(
                                          context,
                                          resumes,
                                        )
                                      : null),
                          ),
                          const SizedBox(height: 10),
                          if (resumes.isEmpty)
                            EmptyDashboard(onCreate: () => _create(context))
                          else
                            ...resumes
                                .take(3)
                                .map(
                                  (resume) => Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 10,
                                    ),
                                    child: ResumeCard(
                                      resume: resume,
                                      onTap: () => context.push(
                                        '/resumes/editor',
                                        extra: resume,
                                      ),
                                      onPreview: () => context.push(
                                        '/resumes/preview',
                                        extra: resume,
                                      ),
                                      onShare: () => _share(context, resume),
                                      onRename: () =>
                                          _rename(context, resume),
                                      onDuplicate: () async {
                                        final copy = await context
                                            .read<ResumesCubit>()
                                            .duplicateResumeData(resume);
                                        if (copy != null && context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                'Resume duplicated',
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      onDelete: () =>
                                          _delete(context, resume),
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 22),
                          DashboardTipCard(resume: latest),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 80,),
                ],
              );
            },
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

  void _showAllResumes(BuildContext context, List<Resume> resumes) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.78,
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: resumes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final resume = resumes[index];
              return ResumeCard(
                resume: resume,
                onTap: () {
                  Navigator.pop(sheetContext);
                  context.push('/resumes/editor', extra: resume);
                },
                onPreview: () {
                  Navigator.pop(sheetContext);
                  context.push('/resumes/preview', extra: resume);
                },
                onShare: () => _share(context, resume),
                onRename: () => _rename(context, resume),
                onDuplicate: () =>
                    context.read<ResumesCubit>().duplicateResumeData(resume),
                onDelete: () => _delete(context, resume),
              );
            },
          ),
        ),
      ),
    );
  }

  void _openPublicResume(BuildContext context, List<Resume> resumes) {
    final publicResume = resumes.firstWhere((r) => r.isPublic);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || publicResume.id.isEmpty) return;
    context.push('/public/resumes/$uid/${publicResume.id}');
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
    } catch (e) {
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
    await context.read<ResumesCubit>().updateResumeData(
      resume.copyWith(title: title),
    );
  }
}