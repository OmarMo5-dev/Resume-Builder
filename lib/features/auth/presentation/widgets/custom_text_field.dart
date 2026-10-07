import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  final Widget? suffixIcon;
  final Widget? prefixIcon;

  final void Function(String)? onFieldSubmitted;

  final bool obscureText;

  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.validator,
    this.suffixIcon,
    this.prefixIcon,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      validator: validator,

      // Close keyboard when the user submits the field.
      onTapOutside: (_) {
        FocusScope.of(context).unfocus();
      },

      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),

      cursorColor: colorScheme.primary,

      decoration: InputDecoration(
        labelText: labelText,

        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),

        floatingLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),

        prefixIcon: prefixIcon,

        suffixIcon: suffixIcon,

        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.error, width: 1.5),
        ),

        errorStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.error,
        ),
      ),
    );
  }
}
