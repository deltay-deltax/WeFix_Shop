import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class InputField extends StatefulWidget {
  final String hint;
  final bool obscureText;
  final TextEditingController? controller;
  final Widget? prefix;
  final bool filled;
  final Color? borderColor;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final bool isPassword;

  const InputField({
    super.key,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.prefix,
    this.filled = true,
    this.borderColor,
    this.fillColor,
    this.keyboardType,
    this.isPassword = false,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText || widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : widget.obscureText,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
        prefixIcon: widget.prefix,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: Colors.grey[600],
                  size: 22,
                ),
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              )
            : null,
        filled: widget.filled,
        fillColor: widget.fillColor ?? AppColors.inputFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: widget.borderColor != null
              ? BorderSide(color: widget.borderColor!)
              : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: widget.borderColor != null
              ? BorderSide(color: widget.borderColor!, width: 1.9)
              : const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 18,
        ),
      ),
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
    );
  }
}
