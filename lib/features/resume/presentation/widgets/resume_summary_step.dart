import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/resume_editor_cubit.dart';
import '../widgets/editor_text_field.dart';

class ResumeSummaryStep extends StatelessWidget {
  final TextEditingController controller;

  const ResumeSummaryStep({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorTextField(
          controller: controller,
          label: 'Professional summary',
          multiline: true,
          textCapitalization: TextCapitalization.sentences,
          hintText:
              'Example: Flutter developer focused on clean, maintainable mobile apps...',
          helperText: 'Aim for 2–4 concise sentences.',
          onChanged: context.read<ResumeEditorCubit>().setSummary,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
              color: cs.primaryContainer.withValues( alpha : .12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 18,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Good summaries answer three questions: who are you, what are you good at, and what value do you bring?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
