import 'package:contact_app/utils/theme/app_constants.dart';
import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final double width;
  final double? height;
  final VoidCallback? onPressed;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.width,
    this.height,
    required this.onPressed,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height ?? 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.backgroundColor,
          disabledForegroundColor: AppConstants.grey, 
          disabledBackgroundColor: AppConstants.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: widget.onPressed,
        child: Text(
          widget.text,
          style: TextStyle(
            color: widget.textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}