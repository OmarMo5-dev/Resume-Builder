import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/resume_editor_cubit.dart';
import '../cubit/resume_editor_state.dart';
import '../widgets/editor_template_selector.dart';
import '../widgets/editor_text_field.dart';

class ResumeBasicsStep extends StatelessWidget {
  final ResumeEditorState state;
  final TextEditingController titleController;

  const ResumeBasicsStep({
    super.key,
    required this.state,
    required this.titleController,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ResumeEditorCubit>();
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorTextField(
          controller: titleController,
          label: 'Resume title',
          prefixIcon: Icons.title_rounded,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          required: true,
          hintText: 'e.g. Flutter Developer Resume',
          helperText: 'This name is only for organizing your resumes.',
          onChanged: cubit.setTitle,
        ),
        const SizedBox(height: 22),
        EditorTemplateSelector(
          selectedId: state.resume.templateId,
          onSelected: cubit.setTemplate,
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues( alpha : .35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.outlineVariant.withValues( alpha : .12)),
          ),
          child: SwitchListTile.adaptive(
            title: const Text(
              'Publish resume',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text('Anyone with the link can view it.'),
            value: state.resume.isPublic,
            onChanged: cubit.setPublic,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 4,
            ),
          ),
        ),
      ],
    );
  }
}
