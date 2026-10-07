import 'package:flutter/material.dart';

/// Declarative description of one text field inside [showEntryDialog].
class EntryField {
  final String key;
  final String label;
  final String initial;
  final TextInputType? keyboard;
  final bool multiline;
  final TextCapitalization capitalization;

  const EntryField(
    this.key,
    this.label, {
    this.initial = '',
    this.keyboard,
    this.multiline = false,
    this.capitalization = TextCapitalization.none,
  });
}

class EntryResult {
  final Map<String, String> _values;
  final bool current;
  const EntryResult(this._values, this.current);

  String operator [](String key) => _values[key] ?? '';

  bool get isAllEmpty {
    for (final v in _values.values) {
      if (v.trim().isNotEmpty) return false;
    }
    return true;
  }
}

/// Shows a form dialog and returns the entered values, or null when the user
/// cancels or saves without entering anything. Controllers are owned by the
/// dialog's State, so they are created once and disposed with the dialog.
Future<EntryResult?> showEntryDialog(
  BuildContext context, {
  required String title,
  required List<EntryField> fields,
  String? currentLabel,
  bool current = false,
}) async {
  final result = await showDialog<EntryResult>(
    context: context,
    builder: (_) => _EntryDialog(title: title, fields: fields, currentLabel: currentLabel, current: current),
  );
  if (result == null || result.isAllEmpty) return null;
  return result;
}

class _EntryDialog extends StatefulWidget {
  final String title;
  final List<EntryField> fields;
  final String? currentLabel;
  final bool current;

  const _EntryDialog({
    required this.title,
    required this.fields,
    required this.currentLabel,
    required this.current,
  });

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  late final Map<String, TextEditingController> _controllers = {
    for (final f in widget.fields) f.key: TextEditingController(text: f.initial),
  };
  late bool _current = widget.current;

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    final values = <String, String>{
      for (final entry in _controllers.entries) entry.key: entry.value.text.trim(),
    };
    Navigator.of(context).pop(EntryResult(values, _current));
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.fields;
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < fields.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: TextField(
                    controller: _controllers[fields[i].key],
                    keyboardType: fields[i].multiline ? TextInputType.multiline : fields[i].keyboard,
                    textCapitalization: fields[i].capitalization,
                    minLines: fields[i].multiline ? 2 : 1,
                    maxLines: fields[i].multiline ? 6 : 1,
                    // Multi-line fields must keep Enter as a newline; other
                    // fields advance, and only the last one says "done".
                    textInputAction: fields[i].multiline
                        ? TextInputAction.newline
                        : (i == fields.length - 1 ? TextInputAction.done : TextInputAction.next),
                    decoration: InputDecoration(labelText: fields[i].label),
                  ),
                ),
              if (widget.currentLabel != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(widget.currentLabel!),
                  value: _current,
                  onChanged: (v) => setState(() => _current = v),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Save')),
      ],
    );
  }
}
