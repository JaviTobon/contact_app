import 'package:contact_app/ui/home/widgets/contact/model/contact_model.dart';

class UserModel {
  final int? id;
  final String username;
  final String email;
  final String password;
  final String? profileImagePath;
  bool firstLogin;
  bool firstContact;
  final List<ContactModel>? contacts;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    this.profileImagePath,
    this.firstLogin = true,
    this.firstContact = true,
    this.contacts,
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'profileImagePath': profileImagePath,
      'firstLogin': firstLogin ? 1 : 0,
      'firstContact': firstContact ? 1 : 0,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      password: map['password'],
      profileImagePath: map['profileImagePath'],
      firstLogin: map['firstLogin'] == 1,
      firstContact: map['firstContact'] == 1,
      contacts: [],
    );
  }
}
