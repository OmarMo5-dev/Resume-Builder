import 'package:flutter/material.dart';

class EmptyResumes extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyResumes({
    super.key,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 72,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),

            const SizedBox(height: 20),

            Text(
              'No resumes yet',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Create your first resume and start building your professional profile.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create Resume'),
            ),
          ],
        ),
      ),
    );
  }
}