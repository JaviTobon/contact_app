import 'dart:async';

import 'package:contact_app/ui/home/widgets/contact/contact_page.dart';
import 'package:contact_app/ui/home/widgets/user_profile/model/user_model.dart';
import 'package:contact_app/ui/home/widgets/user_profile/user_page.dart';
import 'package:contact_app/utils/db/db_helper.dart';
import 'package:contact_app/utils/theme/app_constants.dart';
import 'package:contact_app/utils/widgets/custom_elevated_button.dart';
import 'package:contact_app/utils/widgets/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final String email;

  const HomePage({
    super.key,
    required this.email
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserDBHelper _dbHelper = UserDBHelper.instance;
  int _selectedIndex = 0;
  UserModel? _user;
  Timer? _sessionTimer;

  late Size _size;

  @override
  void initState() {
    super.initState();
    //_printAllUsers(); // TO DO: Print de usuarios para verificación de su data
    _loadUserData(widget.email);
    _sessionTimer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
      _checkSessionExpiration();
    });
  }

  // void _printAllUsers() async {
  //   List<UserModel> users = await _dbHelper.getAllUsers();
    
  //   for (var user in users) {
  //     print('User ID: ${user.id}, Username: ${user.username}, Email: ${user.email}, First: ${user.firstLogin} ${user.firstContact}');
  //   }
  // }

  Future<void> _loadUserData(String email) async {
    UserModel? user = await _dbHelper.getUserByEmail(email);
    if (user != null) {
      setState(() {
        _user = user;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getSelectedPage() {
    if (_selectedIndex == 0) {
      return UserPage(user: _user!);
    } else {
      return ContactPage(user: _user!);
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('session_active');
    await prefs.remove('session_start');
    Navigator.pushReplacementNamed(context, '/login');
  }

  Future<void> _checkSessionExpiration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? sessionStart = prefs.getInt('session_start');
    
    if (sessionStart != null) {
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      print('Tiempo transcurrido: ${currentTime - sessionStart}');
      if (currentTime - sessionStart > 120000) {
        _showSessionExpirationDialog();
      }
    }
  }

  Future<void> _showSessionExpirationDialog() async {
    bool decisionMade = false;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
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
                        'Sesión expirada',
                        style: AppConstants.titleStyle,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tu sesión ha expirado. ¿Te gustaría renovarla o cerrar sesión?',
                        textAlign: TextAlign.center,
                        style: AppConstants.bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomElevatedButton(
                            text: 'Renovar sesión', 
                            backgroundColor: AppConstants.secondaryColor, 
                            textColor: AppConstants.primaryColorDark,
                            width: 140, 
                            onPressed: () {
                              decisionMade = true;
                              Navigator.of(context).pop();
                              _renewSession(); 
                            },
                          ),
                          CustomElevatedButton(
                            text: 'Cerrar sesión', 
                            backgroundColor: AppConstants.lightGrey, 
                            textColor: AppConstants.primaryColorDark, 
                            width: 140, 
                            onPressed: () {
                              decisionMade = true;
                              Navigator.of(context).pop();
                              _logout();
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
        );
      }
    );

    await Future.delayed(const Duration(seconds: 10));
    if (!decisionMade) {
      _logout();
    }
  }

  Future<void> _renewSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('session_start', DateTime.now().millisecondsSinceEpoch);
    
    showCustomSnackBar(
      context,
      'Sesión renovada por 2 minutos más',
      AppConstants.successColor,
      Colors.white,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _user != null ? (_selectedIndex == 0 ? _user!.username : 'Mis contactos') : 'Cargando...',
          style: AppConstants.titleStyle,
        ),
        backgroundColor: AppConstants.primaryColorDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Container(
              height: _size.height,
              color: Colors.white,
              child: _getSelectedPage(),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppConstants.primaryColorDark,
        unselectedItemColor: AppConstants.grey,
        selectedLabelStyle: const TextStyle(
          color: AppConstants.primaryColorDark,
        ),
        unselectedLabelStyle: const TextStyle(
          color: AppConstants.grey,
        ),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person,),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts,),
            label: 'Contactos',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }
}