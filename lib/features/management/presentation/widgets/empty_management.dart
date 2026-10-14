import 'package:flutter/material.dart';

class EmptyManagement extends StatelessWidget {
  const EmptyManagement({super.key, required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.folder_open_rounded, size: 48),
          const SizedBox(height: 12),
          Text(
            'No resumes yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Create your first resume to manage it here.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Create resume'),
          ),
        ],
      ),
    ),
  );
}
