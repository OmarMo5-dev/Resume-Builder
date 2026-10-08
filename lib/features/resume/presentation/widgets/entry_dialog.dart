import 'package:flutter/material.dart';

class EntryField {
  final String key;
  final String label;
  final String initial;
  final String? hintText;
  final String? helperText;
  final TextInputType? keyboard;
  final bool multiline;
  final TextCapitalization capitalization;
  final bool required;

  const EntryField(
    this.key,
    this.label, {
    this.initial = '',
    this.hintText,
    this.helperText,
    this.keyboard,
    this.multiline = false,
    this.capitalization = TextCapitalization.none,
    this.required = false,
  });
}

class EntryResult {
  final Map<String, String> _values;
  final bool current;

  const EntryResult(this._values, this.current);

  String operator [](String key) => _values[key] ?? '';

  bool get isAllEmpty => _values.values.every((value) => value.trim().isEmpty);
}

Future<EntryResult?> showEntryDialog(
  BuildContext context, {
  required String title,
  String? subtitle,
  required List<EntryField> fields,
  String? currentLabel,
  bool current = false,
}) async {
  final result = await showDialog<EntryResult>(
    context: context,
    barrierDismissible: true,
    builder: (_) => _EntryDialog(
      title: title,
      subtitle: subtitle,
      fields: fields,
      currentLabel: currentLabel,
      current: current,
    ),
  );

  if (result == null || result.isAllEmpty) return null;
  return result;
}

class _EntryDialog extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<EntryField> fields;
  final String? currentLabel;
  final bool current;

  const _EntryDialog({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.currentLabel,
    required this.current,
  });

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  late final Map<String, TextEditingController> _controllers = {
    for (final field in widget.fields)
      field.key: TextEditingController(text: field.initial),
  };

  late bool _current = widget.current;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final values = <String, String>{
      for (final entry in _controllers.entries)
        entry.key: entry.value.text.trim(),
    };

    Navigator.of(context).pop(EntryResult(values, _current));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final maxHeight = MediaQuery.sizeOf(context).height * .82;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 560, maxHeight: maxHeight),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  children: [
                    for (var i = 0; i < widget.fields.length; i++) ...[
                      _DialogField(
                        field: widget.fields[i],
                        controller: _controllers[widget.fields[i].key]!,
                      ),
                      if (i != widget.fields.length - 1)
                        const SizedBox(height: 12),
                    ],
                    if (widget.currentLabel != null) ...[
                      const SizedBox(height: 4),
                      Card(
                        elevation: 0,
                        color: cs.surfaceContainerHighest.withValues( alpha : .45),
                        child: SwitchListTile(
                          title: Text(widget.currentLabel!),
                          value: _current,
                          onChanged: (value) =>
                              setState(() => _current = value),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogField extends StatelessWidget {
  final EntryField field;
  final TextEditingController controller;

  const _DialogField({required this.field, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: field.multiline ? TextInputType.multiline : field.keyboard,
      textCapitalization: field.capitalization,
      textInputAction: field.multiline
          ? TextInputAction.newline
          : TextInputAction.next,
      minLines: field.multiline ? 3 : 1,
      maxLines: field.multiline ? 7 : 1,
      scrollPadding: const EdgeInsets.only(bottom: 120),
      decoration: InputDecoration(
        labelText: field.required ? '${field.label} *' : field.label,
        hintText: field.hintText,
        helperText: field.helperText,
        alignLabelWithHint: field.multiline,
      ),
    );
  }
}
