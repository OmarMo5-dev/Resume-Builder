import 'dart:async';
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.onQueryChanged,
    this.hintText = 'Search by title, name, or job title',
    this.isLoading = false,
    this.autofocus = false,
    this.debounce = const Duration(milliseconds: 300),
    this.onSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final String hintText;
  final bool isLoading;
  final bool autofocus;
  final Duration debounce;
  final ValueChanged<String>? onSubmitted;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final FocusNode _focusNode;
  Timer? _debounceTimer;
  bool _hasText = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChanged);
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    if (_isFocused != _focusNode.hasFocus) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
    _scheduleSearch();
  }

  void _scheduleSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onQueryChanged(widget.controller.text.trim());
    });
  }

  void _clear() {
    widget.controller.clear();
    _debounceTimer?.cancel();
    widget.onQueryChanged('');
    if (!_focusNode.hasFocus) _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(16);

    return Semantics(
      label: 'Search field',
      textField: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          cursorColor: cs.primary,
          textInputAction: TextInputAction.search,
          textCapitalization: TextCapitalization.none,
          style: TextStyle(color: cs.onSurface, fontSize: 15),
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          onSubmitted: (value) {
            _debounceTimer?.cancel();
            widget.onQueryChanged(value.trim());
            widget.onSubmitted?.call(value.trim());
          },
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            filled: true,
            fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                Icons.search_rounded,
                color: _isFocused ? cs.primary : cs.onSurfaceVariant,
                size: 22,
              ),
            ),
            suffixIcon: _buildSuffix(cs),
            enabledBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: borderRadius,
              borderSide: BorderSide(color: cs.primary, width: 1.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildSuffix(ColorScheme cs) {
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    if (!_hasText) return null;
    return IconButton(
      tooltip: 'Clear search',
      splashRadius: 20,
      icon: Icon(Icons.close_rounded, size: 20, color: cs.onSurfaceVariant),
      onPressed: _clear,
    );
  }
}
