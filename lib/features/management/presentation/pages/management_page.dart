import 'package:business_os/features/management/presentation/widgets/filter_chips.dart';
import 'package:business_os/features/management/presentation/widgets/search_field.dart';
import 'package:business_os/features/resume/presentation/widgets/resume_loading.dart';
import 'package:business_os/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../resume/domain/entities/resume.dart';
import '../../../resume/presentation/cubit/resumes_cubit.dart';
import '../../../resume/presentation/cubit/resumes_state.dart';
import '../../../resume/presentation/widgets/entry_dialog.dart';
import '../../../resume/presentation/widgets/resume_card.dart';
import '../../../resume/services/resume_pdf_service.dart';
import '../widgets/empty_management.dart';
import '../widgets/sort_bar.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage> {
  final TextEditingController _searchController = TextEditingController();

  JobFilter _filter = JobFilter.all;
  String _query = '';
  ResumeSort _sort = ResumeSort.recentlyUpdated;
  bool _ascending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Resume Management',
        icon: Icons.arrow_back,
        onTap: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/resumes');
          }
        },
        actions: [
          GestureDetector(
            onTap: () => context.read<ResumesCubit>().loadResumes(),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 13),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.refresh_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ResumesCubit, ResumesState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          final message = state.errorMessage;
          if (message != null && message.isNotEmpty && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ResumesStatus.loading) {
            return const ResumeLoading();
          }
          if (state.status == ResumesStatus.failure && state.resumes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_rounded, size: 44),
                    const SizedBox(height: 12),
                    const Text('Could not load your resumes.'),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<ResumesCubit>().loadResumes(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final query = _query.trim().toLowerCase();

          final filtered = state.resumes.where((resume) {
            final matchesQuery =
                query.isEmpty ||
                resume.title.toLowerCase().contains(query) ||
                resume.personalInfo.fullName.toLowerCase().contains(query) ||
                resume.personalInfo.jobTitle.toLowerCase().contains(query);

            final matchesFilter = switch (_filter) {
              JobFilter.drafts => resume.isDraft,
              JobFilter.completed => !resume.isDraft,
              JobFilter.public => resume.isPublic,
              JobFilter.all => true,
            };

            return matchesQuery && matchesFilter;
          }).toList();

          filtered.sort((a, b) {
            final comparison = switch (_sort) {
              ResumeSort.title => a.title.toLowerCase().compareTo(
                b.title.toLowerCase(),
              ),
              ResumeSort.created => a.createdAt.compareTo(b.createdAt),
              ResumeSort.recentlyUpdated => a.updatedAt.compareTo(b.updatedAt),
            };
            return _ascending ? comparison : -comparison;
          });

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              const SizedBox(height: 16),

              SearchField(
                controller: _searchController,
                onQueryChanged: (q) => setState(() => _query = q),
              ),

              const SizedBox(height: 18),
              FilterChips(
                selected: _filter,
                onChanged: (filter) => setState(() => _filter = filter),
              ),

              const SizedBox(height: 14),

              SortBar(
                count: filtered.length,
                itemLabel: filtered.length == 1 ? 'resume' : 'resumes',
                sort: _sort,
                ascending: _ascending,
                onSortChanged: (value) => setState(() => _sort = value),
                onDirectionToggled: () =>
                    setState(() => _ascending = !_ascending),
              ),

              const SizedBox(height: 14),

              if (state.resumes.isEmpty)
                EmptyManagement(
                  onCreate: () async {
                    final resume = await context
                        .read<ResumesCubit>()
                        .createNewResume();
                    if (resume != null && context.mounted) {
                      await context.push('/resumes/editor', extra: resume);
                    }
                    if (context.mounted) {
                      await context.read<ResumesCubit>().loadResumes();
                    }
                  },
                )
              else if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 44,
                        color: cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        query.isNotEmpty
                            ? 'No resumes match your search.'
                            : 'No resumes in this filter.',
                      ),
                      TextButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _filter = JobFilter.all;
                          });
                        },
                        child: const Text('Clear search and filters'),
                      ),
                    ],
                  ),
                )
              else
                for (final resume in filtered)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ResumeCard(
                      resume: resume,
                      onTap: () =>
                          context.push('/resumes/preview', extra: resume),
                      onPreview: () =>
                          context.push('/resumes/preview', extra: resume),
                      onShare: () => _share(context, resume),
                      onRename: () => _rename(context, resume),
                      onDuplicate: () => _duplicate(context, resume),
                      onDelete: () => _delete(context, resume),
                    ),
                  ),
            ],
          );
        },
      ),
    );
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
    final title = (result['title'] ?? '').trim();
    if (title.isEmpty || title == resume.title) return;
    final ok = await context.read<ResumesCubit>().updateResumeData(
      resume.copyWith(title: title),
    );
    if (ok && context.mounted) _message(context, 'Resume renamed');
  }

  Future<void> _duplicate(BuildContext context, Resume resume) async {
    final copy = await context.read<ResumesCubit>().duplicateResumeData(resume);
    if (copy != null && context.mounted) {
      _message(context, 'Resume duplicated');
    }
  }

  Future<void> _delete(BuildContext context, Resume resume) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete resume?'),
        content: Text(
          '"${resume.title}" will be permanently deleted. This cannot be undone.',
        ),
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
    if (confirmed != true || !context.mounted) return;
    final ok = await context.read<ResumesCubit>().deleteResumeById(resume.id);
    if (ok && context.mounted) _message(context, 'Resume deleted');
  }

  Future<void> _share(BuildContext context, Resume resume) async {
    try {
      await ResumePdfService.share(resume);
    } on ResumePdfException catch (error) {
      if (context.mounted) _message(context, error.message);
    } catch (error) {
      if (context.mounted) _message(context, 'PDF sharing failed: $error');
    }
  }

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}
