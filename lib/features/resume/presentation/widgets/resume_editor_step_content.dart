import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/course.dart';
import '../../domain/entities/education.dart';
import '../../domain/entities/experience.dart';
import '../../domain/entities/language.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/skill_group.dart';
import '../cubit/resume_editor_cubit.dart';
import '../cubit/resume_editor_state.dart';
import '../widgets/editor_finish_step.dart';
import '../widgets/editor_list_section.dart';
import '../widgets/step_wrapper.dart';
import 'resume_basics_step.dart';
import 'resume_entry_dialogs.dart';
import 'resume_personal_step.dart';
import 'resume_summary_step.dart';

class ResumeEditorStepContent extends StatelessWidget {
  final int step;

  final VoidCallback onPreview;
  final VoidCallback onExport;
  final VoidCallback onShare;
  final VoidCallback onComplete;

  final TextEditingController titleController;
  final TextEditingController nameController;
  final TextEditingController jobController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController locationController;
  final TextEditingController linkedinController;
  final TextEditingController githubController;
  final TextEditingController websiteController;
  final TextEditingController summaryController;

  final VoidCallback onPersonalChanged;

  const ResumeEditorStepContent({
    super.key,
    required this.step,
    required this.onPreview,
    required this.onExport,
    required this.onShare,
    required this.onComplete,
    required this.titleController,
    required this.nameController,
    required this.jobController,
    required this.emailController,
    required this.phoneController,
    required this.locationController,
    required this.linkedinController,
    required this.githubController,
    required this.websiteController,
    required this.summaryController,
    required this.onPersonalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ResumeEditorCubit, ResumeEditorState>(
      buildWhen: (previous, current) =>
          previous.resume != current.resume || previous.dirty != current.dirty,
      builder: (context, state) {
        switch (step) {
          case 0:
            return EditorStepWrapper(
              title: 'Resume Basics',
              subtitle:
                  'Start with the name and look of your resume. You can change these later.',
              child: ResumeBasicsStep(
                state: state,
                titleController: titleController,
              ),
            );
          case 1:
            return EditorStepWrapper(
              title: 'Personal Information',
              subtitle:
                  'Only add what recruiters need to contact you. You can skip optional links.',
              child: ResumePersonalStep(
                name: nameController,
                job: jobController,
                email: emailController,
                phone: phoneController,
                location: locationController,
                linkedin: linkedinController,
                github: githubController,
                website: websiteController,
                onChanged: onPersonalChanged,
              ),
            );
          case 2:
            return EditorStepWrapper(
              title: 'Professional Summary',
              subtitle:
                  'A short introduction that makes your profile easy to understand.',
              child: ResumeSummaryStep(controller: summaryController),
            );
          case 3:
            return _experience(context, state);
          case 4:
            return _education(context, state);
          case 5:
            return _projects(context, state);
          case 6:
            return _skills(context, state);
          case 7:
            return _more(context, state);
          case 8:
            return EditorFinishStep(
              resume: state.resume,
              onPreview: onPreview,
              onExport: onExport,
              onShare: onShare,
              onComplete: onComplete,
            );
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _experience(BuildContext context, ResumeEditorState state) {
    final resume = state.resume;
    return EditorStepWrapper(
      title: 'Experience',
      subtitle:
          'Add your most relevant roles. Focus on what you achieved, not only what you did.',
      child: EditorListSection<Experience>(
        items: resume.experience,
        emptyMessage: 'No experience added yet',
        emptyIcon: Icons.work_outline_rounded,
        label: (item) => _join(item.position, item.company),
        onAdd: () async {
          final item = await showExperienceEditor(
            context,
            index: resume.experience.length,
          );
          if (item == null || !context.mounted) return;
          final cubit = context.read<ResumeEditorCubit>();
          cubit.setExperience([...resume.experience, item]);
        },
        onEdit: (index) async {
          final item = await showExperienceEditor(
            context,
            item: resume.experience[index],
            index: index,
          );
          if (item == null || !context.mounted) return;
          final copy = [...resume.experience];
          copy[index] = item;
          context.read<ResumeEditorCubit>().setExperience(copy);
        },
        onDelete: (index) {
          final copy = [...resume.experience]..removeAt(index);
          context.read<ResumeEditorCubit>().setExperience(copy);
        },
      ),
    );
  }

  Widget _education(BuildContext context, ResumeEditorState state) {
    final resume = state.resume;
    return EditorStepWrapper(
      title: 'Education',
      subtitle:
          'Add your degree or current studies. Keep the description short.',
      child: EditorListSection<Education>(
        items: resume.education,
        emptyMessage: 'No education added yet',
        emptyIcon: Icons.school_outlined,
        label: (item) => _join(item.degree, item.institution),
        onAdd: () async {
          final item = await showEducationEditor(
            context,
            index: resume.education.length,
          );
          if (item == null || !context.mounted) return;
          context.read<ResumeEditorCubit>().setEducation([
            ...resume.education,
            item,
          ]);
        },
        onEdit: (index) async {
          final item = await showEducationEditor(
            context,
            item: resume.education[index],
            index: index,
          );
          if (item == null || !context.mounted) return;
          final copy = [...resume.education];
          copy[index] = item;
          context.read<ResumeEditorCubit>().setEducation(copy);
        },
        onDelete: (index) {
          final copy = [...resume.education]..removeAt(index);
          context.read<ResumeEditorCubit>().setEducation(copy);
        },
      ),
    );
  }

  Widget _projects(BuildContext context, ResumeEditorState state) {
    final resume = state.resume;
    return EditorStepWrapper(
      title: 'Projects',
      subtitle:
          'Showcase projects that prove your skills. Pick your strongest work.',
      child: EditorListSection<Project>(
        items: resume.projects,
        emptyMessage: 'No projects added yet',
        emptyIcon: Icons.folder_outlined,
        label: (item) => _join(item.name, item.role),
        onAdd: () async {
          final item = await showProjectEditor(
            context,
            index: resume.projects.length,
          );
          if (item == null || !context.mounted) return;
          context.read<ResumeEditorCubit>().setProjects([
            ...resume.projects,
            item,
          ]);
        },
        onEdit: (index) async {
          final item = await showProjectEditor(
            context,
            item: resume.projects[index],
            index: index,
          );
          if (item == null || !context.mounted) return;
          final copy = [...resume.projects];
          copy[index] = item;
          context.read<ResumeEditorCubit>().setProjects(copy);
        },
        onDelete: (index) {
          final copy = [...resume.projects]..removeAt(index);
          context.read<ResumeEditorCubit>().setProjects(copy);
        },
      ),
    );
  }

  Widget _skills(BuildContext context, ResumeEditorState state) {
    final resume = state.resume;
    return EditorStepWrapper(
      title: 'Skills',
      subtitle: 'Group skills by category so recruiters can scan them quickly.',
      child: EditorListSection<SkillGroup>(
        items: resume.skills,
        emptyMessage: 'No skills added yet',
        emptyIcon: Icons.auto_awesome_outlined,
        label: (item) => item.items.isEmpty
            ? item.category
            : '${item.category}: ${item.items.join(', ')}',
        onAdd: () async {
          final item = await showSkillEditor(
            context,
            index: resume.skills.length,
          );
          if (item == null || !context.mounted) return;
          context.read<ResumeEditorCubit>().setSkills([...resume.skills, item]);
        },
        onEdit: (index) async {
          final item = await showSkillEditor(
            context,
            item: resume.skills[index],
            index: index,
          );
          if (item == null || !context.mounted) return;
          final copy = [...resume.skills];
          copy[index] = item;
          context.read<ResumeEditorCubit>().setSkills(copy);
        },
        onDelete: (index) {
          final copy = [...resume.skills]..removeAt(index);
          context.read<ResumeEditorCubit>().setSkills(copy);
        },
      ),
    );
  }

  Widget _more(BuildContext context, ResumeEditorState state) {
    final resume = state.resume;

    return EditorStepWrapper(
      title: 'Courses & Languages',
      subtitle:
          'Add extra credentials only when they strengthen your application.',
      child: Column(
        children: [
          EditorListSection<Course>(
            items: resume.courses,
            emptyMessage: 'No courses added yet',
            emptyIcon: Icons.card_membership_outlined,
            label: (item) => _join(item.name, item.provider),
            onAdd: () async {
              final item = await showCourseEditor(
                context,
                index: resume.courses.length,
              );
              if (item == null || !context.mounted) return;
              context.read<ResumeEditorCubit>().setCourses([
                ...resume.courses,
                item,
              ]);
            },
            onEdit: (index) async {
              final item = await showCourseEditor(
                context,
                item: resume.courses[index],
                index: index,
              );
              if (item == null || !context.mounted) return;
              final copy = [...resume.courses];
              copy[index] = item;
              context.read<ResumeEditorCubit>().setCourses(copy);
            },
            onDelete: (index) {
              final copy = [...resume.courses]..removeAt(index);
              context.read<ResumeEditorCubit>().setCourses(copy);
            },
          ),
          const SizedBox(height: 18),
          EditorListSection<Language>(
            items: resume.languages,
            emptyMessage: 'No languages added yet',
            emptyIcon: Icons.translate_outlined,
            label: (item) => _join(item.name, item.level),
            onAdd: () async {
              final item = await showLanguageEditor(
                context,
                index: resume.languages.length,
              );
              if (item == null || !context.mounted) return;
              context.read<ResumeEditorCubit>().setLanguages([
                ...resume.languages,
                item,
              ]);
            },
            onEdit: (index) async {
              final item = await showLanguageEditor(
                context,
                item: resume.languages[index],
                index: index,
              );
              if (item == null || !context.mounted) return;
              final copy = [...resume.languages];
              copy[index] = item;
              context.read<ResumeEditorCubit>().setLanguages(copy);
            },
            onDelete: (index) {
              final copy = [...resume.languages]..removeAt(index);
              context.read<ResumeEditorCubit>().setLanguages(copy);
            },
          ),
        ],
      ),
    );
  }

  static String _join(String first, String second) {
    final a = first.trim();
    final b = second.trim();

    if (a.isNotEmpty && b.isNotEmpty) return '$a — $b';
    return a.isNotEmpty ? a : (b.isNotEmpty ? b : '(untitled)');
  }
}
