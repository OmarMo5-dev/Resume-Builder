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
    final colors = theme.colorScheme;
    final isDraft = resume.isDraft;

    final cs = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = (isDark ? cs.surfaceContainerHigh : Colors.white);

    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 9, 4, 9),
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
          child: Row(
            children: [
              _ResumeThumbnail(isDraft: isDraft),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resume.title.trim().isEmpty
                          ? 'Untitled resume'
                          : resume.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      resume.personalInfo.jobTitle.trim().isEmpty
                          ? (isDraft
                                ? 'Keep editing your resume'
                                : 'Resume ready')
                          : resume.personalInfo.jobTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDraft ? colors.tertiary : colors.primary,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isDraft ? 'Draft' : 'Ready',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDraft ? colors.tertiary : colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (resume.isPublic) ...[
                          const SizedBox(width: 9),
                          Icon(
                            Icons.public_rounded,
                            size: 12,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            'Public',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 2),
              IconButton(
                tooltip: 'Share PDF',
                onPressed: onShare,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(
                  width: 36,
                  height: 36,
                ),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.ios_share_rounded, size: 18),
              ),
              PopupMenuButton<String>(
                tooltip: 'More options',
                iconSize: 20,
                padding: EdgeInsets.zero,
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
                itemBuilder: (_) => [
                  _menuItem('open', Icons.edit_outlined, 'Edit'),
                  _menuItem('preview', Icons.visibility_outlined, 'Preview'),
                  _menuItem(
                    'rename',
                    Icons.drive_file_rename_outline,
                    'Rename',
                  ),
                  _menuItem('duplicate', Icons.copy_rounded, 'Duplicate'),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: SizedBox(
                      width: 168,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: colors.error,
                          ),
                          const SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: colors.error)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) {
    return PopupMenuItem<String>(
      value: value,
      child: SizedBox(
        width: 168,
        child: Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumeThumbnail extends StatelessWidget {
  final bool isDraft;

  const _ResumeThumbnail({required this.isDraft});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 42,
      height: 52,
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            isDraft ? Icons.edit_document : Icons.description_outlined,
            color: colors.onPrimary,
            size: 23,
          ),
          Positioned(
            bottom: 7,
            child: Container(
              width: 16,
              height: 2,
              decoration: BoxDecoration(
                color: colors.onPrimary.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
