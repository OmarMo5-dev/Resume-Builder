import 'package:flutter/material.dart';

class EditorTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final String? hintText;
  final String? helperText;
  final bool multiline;
  final bool required;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const EditorTextField({
    super.key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction,
    this.hintText,
    this.helperText,
    this.multiline = false,
    this.required = false,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<EditorTextField> createState() => _EditorTextFieldState();
}

class _EditorTextFieldState extends State<EditorTextField> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocus);
  }

  void _handleFocus() {
    if (!_focusNode.hasFocus || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focusNode.hasFocus) return;

      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: .18,
      );
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocus);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      onTapOutside: (_) => _focusNode.unfocus(),
      keyboardType: widget.multiline
          ? TextInputType.multiline
          : widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      textInputAction:
          widget.textInputAction ??
          (widget.multiline ? TextInputAction.newline : TextInputAction.next),
      minLines: widget.multiline ? 5 : 1,
      maxLines: widget.multiline ? 10 : 1,
      scrollPadding: const EdgeInsets.only(bottom: 140),
      autocorrect: widget.keyboardType == null,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon),
        suffixIcon: widget.suffixIcon,
        alignLabelWithHint: widget.multiline,
      ),
    );
  }
}
