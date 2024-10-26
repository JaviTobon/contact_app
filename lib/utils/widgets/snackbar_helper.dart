import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, String message, Color backgroundColor, Color textColor) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor),
      ),
      backgroundColor: backgroundColor,
      duration: const Duration(seconds: 3),
    ),
  );
}
