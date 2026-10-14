import 'package:flutter/material.dart';

import '../../domain/entities/resume_social_link.dart';
import '../widgets/editor_text_field.dart';

class ResumePersonalStep extends StatelessWidget {
  final TextEditingController name;
  final TextEditingController job;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController location;
  final TextEditingController linkedin;
  final TextEditingController github;
  final TextEditingController website;
  final List<ResumeSocialLink> socialLinks;
  final ValueChanged<List<ResumeSocialLink>> onSocialLinksChanged;
  final VoidCallback onChanged;

  const ResumePersonalStep({
    super.key,
    required this.name,
    required this.job,
    required this.email,
    required this.phone,
    required this.location,
    required this.linkedin,
    required this.github,
    required this.website,
    required this.socialLinks,
    required this.onSocialLinksChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EditorTextField(
          controller: name,
          label: 'Full name',
          prefixIcon: Icons.person_outline_rounded,
          textCapitalization: TextCapitalization.words,
          required: true,
          hintText: 'Your full name',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: job,
          label: 'Professional title',
          prefixIcon: Icons.work_outline_rounded,
          textCapitalization: TextCapitalization.words,
          required: true,
          hintText: 'e.g. Translator, Accountant, Teacher, Marketing Specialist',
          helperText: 'Use the professional title that best describes you.',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: email,
          label: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          required: true,
          hintText: 'name@example.com',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: phone,
          label: 'Phone',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          hintText: '+20 ...',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: location,
          label: 'Location',
          prefixIcon: Icons.location_on_outlined,
          textCapitalization: TextCapitalization.words,
          hintText: 'Cairo, Egypt',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: linkedin,
          label: 'LinkedIn',
          prefixIcon: Icons.business_center_outlined,
          keyboardType: TextInputType.url,
          hintText: 'linkedin.com/in/...',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: github,
          label: 'GitHub',
          prefixIcon: Icons.code_outlined,
          keyboardType: TextInputType.url,
          hintText: 'github.com/...',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 14),
        EditorTextField(
          controller: website,
          label: 'Website / Portfolio',
          prefixIcon: Icons.link_outlined,
          keyboardType: TextInputType.url,
          hintText: 'yourwebsite.com',
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 18),
        _AdditionalLinksSection(
          links: socialLinks,
          onChanged: onSocialLinksChanged,
        ),
      ],
    );
  }
}

class _AdditionalLinksSection extends StatelessWidget {
  final List<ResumeSocialLink> links;
  final ValueChanged<List<ResumeSocialLink>> onChanged;

  const _AdditionalLinksSection({required this.links, required this.onChanged});

  Future<void> _edit(BuildContext context, {ResumeSocialLink? existing}) async {
    final platform = TextEditingController(text: existing?.platform ?? '');
    final url = TextEditingController(text: existing?.url ?? '');
    final result = await showDialog<ResumeSocialLink>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(existing == null ? 'Add professional link' : 'Edit professional link'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: platform,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Platform / label',
                hintText: 'e.g. ResearchGate, Behance, Booking profile',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final label = platform.text.trim();
              final address = url.text.trim();
              if (label.isEmpty || address.isEmpty) return;
              Navigator.pop(dialogContext, ResumeSocialLink(
                id: existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
                platform: label,
                url: address,
              ));
            },
            child: const Text('Save link'),
          ),
        ],
      ),
    );
    platform.dispose();
    url.dispose();
    if (result == null) return;
    final next = [...links];
    final index = next.indexWhere((link) => link.id == result.id);
    if (index < 0) {
      next.add(result);
    } else {
      next[index] = result;
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: .12)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Additional professional links (optional)', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'Add only links relevant to your work. Empty links will not appear on the CV.',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          for (final link in links) ...[
            const SizedBox(height: 8),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(_iconFor(link.platform)),
              title: Text(link.platform),
              subtitle: Text(link.url, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: Wrap(
                spacing: 0,
                children: [
                  IconButton(tooltip: 'Edit link', icon: const Icon(Icons.edit_outlined), onPressed: () => _edit(context, existing: link)),
                  IconButton(tooltip: 'Remove link', icon: const Icon(Icons.delete_outline), onPressed: () => onChanged(links.where((item) => item.id != link.id).toList())),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: .12)
              )
            ),
            onPressed: () => _edit(context),
            icon: const Icon(Icons.add_link),
            label: const Text('Add link'),
          ),
        ],
      ),
    );
  }

  static IconData _iconFor(String platform) {
    final value = platform.toLowerCase();
    if (value.contains('github')) return Icons.code_rounded;
    if (value.contains('linkedin')) return Icons.business_center_outlined;
    if (value.contains('research')) return Icons.science_outlined;
    if (value.contains('behance') || value.contains('design')) return Icons.palette_outlined;
    if (value.contains('youtube') || value.contains('video')) return Icons.play_circle_outline;
    return Icons.link_rounded;
  }
}

