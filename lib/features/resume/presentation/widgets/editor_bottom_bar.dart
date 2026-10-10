import 'package:flutter/material.dart';

class EditorBottomBar extends StatelessWidget {
  final int currentIndex;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSaveDraft;
  final VoidCallback onComplete;

  const EditorBottomBar({
    super.key,
    required this.currentIndex,
    required this.totalSteps,
    required this.isSaving,
    required this.onBack,
    required this.onNext,
    required this.onSaveDraft,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isFirst = currentIndex == 0;
    final isLast = currentIndex == totalSteps - 1;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.outlineVariant.withValues( alpha : .2), width: .5),
        ),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        child: Row(
          children: [
            if (!isFirst) ...[
              OutlinedButton(
                onPressed: isSaving ? null : onBack,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(color: cs.outlineVariant.withValues( alpha : .12))
                ),
                child: const Icon(Icons.arrow_back_rounded, size: 19),
              ),
              const SizedBox(width: 8),
            ],
            IconButton.outlined(
              tooltip: 'Save Draft',
              onPressed: isSaving ? null : onSaveDraft,
              style: IconButton.styleFrom(
                minimumSize: const Size(48, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: BorderSide(color: cs.outlineVariant.withValues( alpha : .12))
              ),
              icon: const Icon(Icons.save_outlined, size: 20),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isLast
                  ? FilledButton.icon(
                      onPressed: isSaving ? null : onComplete,
                      style: _buttonStyle(),
                      icon: isSaving
                          ? const SizedBox(
                              width: 17,
                              height: 17,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline, size: 18),
                      label: Text(isSaving ? 'Saving…' : 'Complete Resume'),
                    )
                  : FilledButton.icon(
                      onPressed: isSaving ? null : onNext,
                      style: _buttonStyle(),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: const Text('Next'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ButtonStyle _buttonStyle() => FilledButton.styleFrom(
    minimumSize: const Size.fromHeight(48),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}
