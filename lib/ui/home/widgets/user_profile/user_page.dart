import 'package:flutter/material.dart';
import 'package:contact_app/utils/db/db_helper.dart';
import 'dart:io';
import 'package:contact_app/ui/home/widgets/user_profile/model/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:contact_app/utils/theme/app_constants.dart';

class UserPage extends StatefulWidget {
  final UserModel user;

  const UserPage({
    super.key,
    required this.user,
  });

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final UserDBHelper _dbHelper = UserDBHelper.instance;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadUserData(widget.user.email);
  }

  void _loadUserData(String email) {
    setState(() {
      if (widget.user.profileImagePath != null) {
        _profileImage = File(widget.user.profileImagePath!);
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });

      await _dbHelper.updateUserProfileImage(widget.user.email, pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                _showImageSourceDialog();
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : null,
                child: _profileImage == null
                    ? ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.grey.withOpacity(0.1),
                          BlendMode.srcATop,
                        ),
                        child: Image.asset('assets/icons/app_logo.png'),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Información personal',
            style: AppConstants.titleStyle,
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Nombre completo: ',
                  style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: widget.user.username,
                  style: AppConstants.infoTextStyle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Email: ',
                  style: AppConstants.bodyStyle.copyWith(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: widget.user.email,
                  style: AppConstants.infoTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Seleccionar de la galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}