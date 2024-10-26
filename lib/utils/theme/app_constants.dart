import 'package:flutter/material.dart';

class AppConstants {
  // Paleta de colores
  static const Color primaryColorDark = Color(0xff0F1A36);
  static const Color secondaryColor = Color(0xFFFFC23F);
  static const Color backgroundColor = Color(0xffF0F0F0);
  static const Color titleColor = Color(0xff217085);
  static const Color textColor = Colors.black;
  static const Color grey = Color(0xff6E6E70);
  static const Color lightGrey = Color(0xffB3B2B7);
  static const Color darkGrey = Color(0xff323234);
  static const Color errorColor = Color(0xffFF0000);
  static const Color successColor = Color(0xff00C614);
  static const Color buttonColor = Color(0xFFF8C91C);

  // Estilos de texto
  static const TextStyle titleStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: secondaryColor,
  );

  static const TextStyle labelStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: primaryColorDark,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static const TextStyle infoTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: grey,
  );
}
