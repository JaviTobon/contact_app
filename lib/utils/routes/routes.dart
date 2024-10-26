import 'package:contact_app/ui/auth/login_page.dart';
import 'package:contact_app/ui/auth/register_page.dart';
import 'package:contact_app/ui/home/home_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String user = '/user';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case user:
        final String email = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => HomePage(email: email));
      default:
        return MaterialPageRoute(builder: (_) => const LoginPage());
    }
  }
}
