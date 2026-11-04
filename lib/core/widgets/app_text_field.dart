import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool showCounter;
  final bool readOnly;
  final bool? enabled;

  const AppTextField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.showCounter = false,
    this.readOnly = false,
    this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPhone = keyboardType == TextInputType.phone;
    final List<TextInputFormatter>? effectiveFormatters = inputFormatters ??
        (isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ]
            : null);
    final int? effectiveMaxLength = maxLength ?? (isPhone ? 11 : null);

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      enabled: enabled,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: isPassword ? 1 : maxLines,
      maxLength: effectiveMaxLength,
      inputFormatters: effectiveFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: showCounter ? null : '',
      ),
    );
  }
}
