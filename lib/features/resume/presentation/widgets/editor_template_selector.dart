import 'package:flutter/material.dart';

class ResumeTemplate {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  const ResumeTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
}

class EditorTemplateSelector extends StatelessWidget {
  final String selectedId;
  final ValueChanged<String> onSelected;

  const EditorTemplateSelector({
    super.key,
    required this.selectedId,
    required this.onSelected,
  });

  static const templates = [
    ResumeTemplate(
      id: 'classic_01',
      name: 'Classic ATS',
      description: 'Simple and recruiter-friendly',
      icon: Icons.article_outlined,
    ),
    ResumeTemplate(
      id: 'modern_01',
      name: 'Modern ATS',
      description: 'Clean with a modern feel',
      icon: Icons.auto_awesome_outlined,
    ),
    ResumeTemplate(
      id: 'minimal_01',
      name: 'Minimal ATS',
      description: 'Minimal and focused',
      icon: Icons.space_bar_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a template',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'You can change this later.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 4),
            itemCount: templates.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final template = templates[index];
              final selected = template.id == selectedId;

              return _TemplateCard(
                template: template,
                selected: selected,
                onTap: () => onSelected(template.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  final ResumeTemplate template;
  final bool selected;
  final VoidCallback onTap;

  const _TemplateCard({
    required this.template,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Semantics(
      button: true,
      selected: selected,
      label: '${template.name}. ${template.description}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 130,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? cs.primaryContainer.withValues( alpha : .15)
                : cs.surfaceContainerHighest.withValues( alpha : .35),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? cs.primary.withValues(alpha: 0.12) : cs.outlineVariant.withValues(alpha: 0.12),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected ? cs.primary : cs.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      template.icon,
                      size: 18,
                      color: selected ? cs.onPrimary : cs.primary,
                    ),
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: cs.primary,
                      size: 20,
                    ),
                ],
              ),
              const Spacer(),
              Text(
                template.name,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                template.description,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
