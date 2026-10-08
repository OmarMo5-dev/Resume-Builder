import 'package:flutter/material.dart';
import '../../domain/entities/resume.dart';

class ResumeCard extends StatelessWidget {
  final Resume resume;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onPreview;
  final VoidCallback onShare;

  const ResumeCard({
    super.key,
    required this.resume,
    required this.onTap,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
    required this.onPreview,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues( alpha : 0.35),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: cs.outlineVariant.withValues( alpha : 0.1),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail
              Container(
                width: 52,
                height: 66,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      cs.primaryContainer,
                      cs.primaryContainer.withValues( alpha : 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  resume.isDraft
                      ? Icons.edit_document
                      : Icons.description_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Title + subtitle + chips
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      resume.personalInfo.jobTitle.isEmpty
                          ? (resume.isDraft ? 'Draft' : 'Completed')
                          : resume.personalInfo.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _StatusChip(
                          text: resume.isDraft ? 'Draft' : 'Ready',
                          icon: resume.isDraft
                              ? Icons.edit_outlined
                              : Icons.check_circle_outline,
                          tone: resume.isDraft
                              ? _ChipTone.neutral
                              : _ChipTone.success,
                        ),
                        if (resume.isPublic)
                          const _StatusChip(
                            text: 'Public',
                            icon: Icons.public_outlined,
                            tone: _ChipTone.info,
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Share PDF',
                    visualDensity: VisualDensity.compact,
                    onPressed: onShare,
                    icon: const Icon(Icons.ios_share_outlined, size: 20),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'More',
                    icon: const Icon(Icons.more_vert_rounded, size: 20),
                    onSelected: (value) {
                      switch (value) {
                        case 'open':
                          onTap();
                          break;
                        case 'preview':
                          onPreview();
                          break;
                        case 'rename':
                          onRename();
                          break;
                        case 'duplicate':
                          onDuplicate();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'open',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'preview',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.visibility_outlined),
                          title: Text('Preview'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rename',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.drive_file_rename_outline),
                          title: Text('Rename'),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.copy_all_outlined),
                          title: Text('Duplicate'),
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.delete_outline),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _ChipTone { neutral, success, info }

class _StatusChip extends StatelessWidget {
  final String text;
  final IconData icon;
  final _ChipTone tone;

  const _StatusChip({
    required this.text,
    required this.icon,
    this.tone = _ChipTone.neutral,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    late Color bg, fg;
    switch (tone) {
      case _ChipTone.success:
        bg = cs.primaryContainer.withValues( alpha : 0.7);
        fg = cs.onPrimaryContainer;
        break;
      case _ChipTone.info:
        bg = cs.tertiaryContainer.withValues( alpha : 0.7);
        fg = cs.onTertiaryContainer;
        break;
      case _ChipTone.neutral:
        bg = cs.surfaceContainerHighest;
        fg = cs.onSurfaceVariant;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
