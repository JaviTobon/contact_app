import 'package:contact_app/ui/home/widgets/user_profile/model/user_model.dart';
import 'package:contact_app/utils/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:contact_app/utils/db/db_helper.dart';
import 'package:contact_app/utils/mixins/validation_mixin.dart';
import 'package:contact_app/utils/theme/app_constants.dart';
import 'package:contact_app/utils/widgets/custom_elevated_button.dart';
import 'package:contact_app/utils/widgets/custom_text_form_field.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UserDBHelper _dbHelper = UserDBHelper.instance;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  bool _isButtonEnabled = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _biometricSupported = false;
  bool _biometricEnabled = false;
  bool _isFirstLogin = true;

  late Size _size;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
    _emailController.addListener(_checkFields);
    _passwordController.addListener(_checkFields);
  }

  Future<void> _checkBiometricSupport() async {
    bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool biometricEnabled = prefs.getBool('biometric_enabled') ?? false;

    setState(() {
      _biometricSupported = canCheckBiometrics;
      _biometricEnabled = biometricEnabled;
    });
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }
  
  Future<void> _showBiometricDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                ),
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Autenticación biométrica',
                        style: AppConstants.titleStyle,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '¿Te gustaría usar autenticación biométrica para futuros inicios de sesión?',
                        textAlign: TextAlign.center,
                        style: AppConstants.bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      CustomElevatedButton(
                        text: 'Sí, usar biometría', 
                        backgroundColor: AppConstants.secondaryColor, 
                        textColor: AppConstants.primaryColorDark,
                        width: 160, 
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await _enableBiometricAuth();
                        },
                      ),
                      const SizedBox(height: 12),
                      CustomElevatedButton(
                        text: 'No, gracias', 
                        backgroundColor: AppConstants.lightGrey, 
                        textColor: AppConstants.primaryColorDark, 
                        width: 160, 
                        onPressed: () {
                          Navigator.of(context).pop();
                          _proceedWithLogin();
                        },
                      ),                      
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _enableBiometricAuth() async {
    bool authenticated = await _authenticateWithBiometrics(isFirstLogin: _isFirstLogin);

    if (authenticated) {
      await _updateFirstLoginFlag();
      _proceedWithLogin();
    } else {
      showCustomSnackBar(
        context,
        'Error al autenticar usando biometría',
        AppConstants.errorColor,
        Colors.white,
      );
    }
  }

  Future<void> _updateFirstLoginFlag() async {
    UserModel? user = await _dbHelper.getUserByEmail(_emailController.text);

    if (user != null) {
      user.firstLogin = false;
      await _dbHelper.updateUser(user);
    }
  }

  void _saveCredentialValues(String email, String password, bool biometricEnabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(key: 'email', value: _emailController.text);
    await _secureStorage.write(key: 'password', value: _passwordController.text);

    await prefs.setBool('biometric_enabled', biometricEnabled);
    await prefs.setBool('session_active', true);
    await prefs.setInt('session_start', DateTime.now().millisecondsSinceEpoch);
  }

  void _proceedWithLogin() {
    showCustomSnackBar(
      context,
      'Inicio de sesión exitoso',
      AppConstants.successColor,
      Colors.white,
    );
    Navigator.pushReplacementNamed(context, '/user', arguments: _emailController.text);
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      UserModel? user = await _dbHelper.getUserByEmail(_emailController.text);
      if (user != null && user.password == _passwordController.text) {
        setState(() {
          _isFirstLogin = user.firstLogin;
        });
        if (user.firstLogin) {
          _showBiometricDialog();
        } else {
          _saveCredentialValues(_emailController.text, _passwordController.text, false);
          _proceedWithLogin();
        }
      } else {
        showCustomSnackBar(
          context,
          'Correo o contraseña incorrectos',
          AppConstants.errorColor,
          Colors.white,
        );
      }
    }
  }

  Future<bool> _authenticateWithBiometrics({required bool isFirstLogin}) async {
    try {
      bool authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor autentícate usando biometría',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        if (!isFirstLogin) {
          String? email = await _secureStorage.read(key: 'email');
          String? password = await _secureStorage.read(key: 'password');

          if (email != null && password != null) {
            UserModel? user = await _dbHelper.getUserByEmail(email);
            if (user != null && user.password == password) {
              _saveCredentialValues(user.email, user.password, true);
              showCustomSnackBar(
                context,
                'Autenticación biométrica exitosa',
                AppConstants.successColor,
                Colors.white,
              );
              return true;
            }
          }
        } else {
          _saveCredentialValues(_emailController.text, _passwordController.text, true);
          showCustomSnackBar(
            context,
            'Autenticación biométrica exitosa',
            AppConstants.successColor,
            Colors.white,
          );
          return true;
        }
      }

      showCustomSnackBar(
        context,
        'Autenticación biométrica fallida',
        AppConstants.errorColor,
        Colors.white,
      );
      return false;
    } catch (e) {
      showCustomSnackBar(
        context,
        'Error durante la autenticación: $e',
        AppConstants.errorColor,
        Colors.white,
      );
      return false;
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
              child: Image.asset(
                'assets/images/banner_login.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                SizedBox(height: _size.height * 0.25),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Container(
                      width: _size.width,
                      padding: const EdgeInsets.all(18.0),
                      decoration: BoxDecoration(
                        color: const Color(0xff323234).withOpacity(0.9),
                        borderRadius: const BorderRadius.all(Radius.circular(24)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Center(
                              child: Text(
                                'Iniciar sesión',
                                textAlign: TextAlign.left,
                                style: AppConstants.titleStyle,
                              ),
                            ),
                            const SizedBox(height: 24),
                            CustomTextFormField(
                              title: 'Correo electrónico',
                              placeholder: 'Ingresa tu correo',
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
                            if (_biometricSupported && _biometricEnabled)
                              IconButton(
                                icon: const Icon(Icons.fingerprint),
                                color: Colors.white,
                                iconSize: 40,
                                onPressed: () {
                                  _authenticateWithBiometrics(isFirstLogin: _isFirstLogin);
                                },
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '¿No tienes una cuenta?',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: AppConstants.lightGrey,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/register');
                                  },
                                  child: const Text(
                                    'Regístrate aquí',
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
                                  text: "Ingresar",
                                  backgroundColor: AppConstants.buttonColor,
                                  textColor: AppConstants.primaryColorDark,
                                  width: 150,
                                  onPressed: _isButtonEnabled ? _login : null, 
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
