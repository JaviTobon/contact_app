import 'package:contact_app/utils/theme/app_constants.dart';
import 'package:contact_app/utils/widgets/custom_elevated_button.dart';
import 'package:contact_app/utils/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:contact_app/utils/mixins/validation_mixin.dart';
import 'package:contact_app/utils/widgets/custom_text_form_field.dart';
import 'package:contact_app/ui/home/widgets/user_profile/model/user_model.dart';
import 'package:contact_app/utils/db/db_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late Size _size;
  final UserDBHelper _dbHelper = UserDBHelper.instance;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      UserModel newUser = UserModel(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        profileImagePath: null,
      );

      int userId = await _dbHelper.insertUser(newUser);

      if (userId > 0) {
        showCustomSnackBar(
          context,
          'Usuario registrado exitosamente',
          AppConstants.successColor,
          Colors.white,
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        showCustomSnackBar(
          context,
          'Error al registrar el usuario',
          AppConstants.errorColor,
          Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(
              width: _size.width,
              height: _size.height,
              child: Stack(
                children: [
                  SizedBox(
                    width: _size.width,
                    height: _size.height,
                    child: Image.asset(
                      'assets/images/banner_login.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SizedBox(height: _size.height * 0.14),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      width: _size.width,
                      height: _size.height * 0.7,
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: const Color(0xff323234).withOpacity(0.9),
                        borderRadius: const BorderRadius.all(Radius.circular(24))
                      ),
                      child: Form(
                        key: _formKey,
                        child: ListView(
                          children: [
                            const Center(
                              child: Text(
                                'Crear cuenta',
                                textAlign: TextAlign.left,
                                style: AppConstants.titleStyle,
                              ),
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              title: 'Nombre de usuario',
                              placeholder: 'Ingresa tu nombre',
                              controller: _usernameController,
                              validator: validateUsername,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                              ],
                              textColor: Colors.white,
                              prefixIcon: Icons.person,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              title: 'Correo electrónico',
                              placeholder: 'ejemplo@correo.com',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: validateEmail,
                              textColor: Colors.white,
                              prefixIcon: Icons.email,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              title: 'Contraseña',
                              placeholder: 'Ingresa tu contraseña',
                              controller: _passwordController,
                              obscureText: true,
                              validator: validatePassword,
                              isPasswordField: true,
                              textColor: Colors.white,
                              prefixIcon: Icons.lock,
                            ),
                            const SizedBox(height: 12),
                            CustomTextFormField(
                              title: 'Confirmar contraseña',
                              placeholder: 'Repite tu contraseña',
                              controller: _confirmPasswordController,
                              obscureText: true,
                              validator: (value) => validateConfirmPassword(value, _passwordController.text),
                              isPasswordField: true,
                              textColor: Colors.white,
                              prefixIcon: Icons.lock,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '¿Ya tienes una cuenta?',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppConstants.lightGrey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/login');
                                  },
                                  child: const Text(
                                    'Inicia sesión',
                                    style: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomElevatedButton(
                                  text: "Confirmar",
                                  backgroundColor: AppConstants.buttonColor,
                                  textColor: AppConstants.primaryColorDark,
                                  width: 150,
                                  onPressed: () {
                                    _register();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();    
    super.dispose();
  }
}