import 'package:contact_app/utils/theme/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFormField extends StatefulWidget {
  final String title;
  final String placeholder;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final bool isPasswordField;
  final Color? textColor;
  final IconData? prefixIcon;

  const CustomTextFormField({
    super.key,
    required this.title,
    required this.placeholder,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.obscureText = false,
    this.inputFormatters,
    this.isPasswordField = false,
    this.textColor,
    this.prefixIcon
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _hasFocus = false;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: AppConstants.labelStyle.copyWith(color: widget.textColor),
        ),
        const SizedBox(height: 8),
        Focus(
          onFocusChange: (focus) {
            setState(() {
              _hasFocus = focus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.isPasswordField ? _obscureText : widget.obscureText,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              filled: true,
              fillColor: Colors.white,
              hintText: widget.placeholder,
              hintStyle: const TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _hasFocus ? AppConstants.primaryColorDark : AppConstants.grey, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppConstants.errorColor, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppConstants.errorColor, width: 2),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon, 
                      color: _hasFocus ? AppConstants.primaryColorDark : AppConstants.grey,
                    )
                  : null,
              suffixIcon: widget.isPasswordField
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: _hasFocus ? AppConstants.primaryColorDark : AppConstants.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            ),
          ),
        ),
      ],
    );
  }
}