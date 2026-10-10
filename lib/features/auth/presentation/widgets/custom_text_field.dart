import 'package:flutter/material.dart';

/// Shared, lightweight text field for authentication screens.
class CustomTextField extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      validator: validator,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colors.onSurface,
      ),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          fontSize: 14,
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        floatingLabelStyle: TextStyle(
          color: colors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: prefixIcon == null
            ? null
            : IconTheme(
                data: IconThemeData(color: colors.onSurfaceVariant, size: 20),
                child: prefixIcon!,
              ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
        border: border(colors.outlineVariant.withValues(alpha: 0.01)),
        enabledBorder: border(colors.outlineVariant),
        focusedBorder: border(colors.primary, 1.3),
        errorBorder: border(colors.error),
        focusedErrorBorder: border(colors.error, 1.3),
        errorStyle: TextStyle(color: colors.error, fontSize: 11.5, height: 1.2),
      ),
    );
  }
}
