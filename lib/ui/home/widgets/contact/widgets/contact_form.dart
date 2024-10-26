import 'package:contact_app/ui/home/widgets/contact/model/contact_model.dart';
import 'package:contact_app/utils/mixins/validation_mixin.dart';
import 'package:contact_app/utils/theme/app_constants.dart';
import 'package:contact_app/utils/widgets/custom_elevated_button.dart';
import 'package:contact_app/utils/widgets/custom_text_form_field.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:contact_app/utils/db/db_helper.dart';

class ContactForm extends StatefulWidget {
  final int userId;
  final VoidCallback onCancel;
  final VoidCallback onSave;
  final ContactModel? contact;
  final bool isLocalContact;

  const ContactForm({
    super.key,
    required this.userId,
    required this.onCancel,
    required this.onSave,
    this.contact,
    this.isLocalContact = false,
  });

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> with ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _contactName = TextEditingController();
  final TextEditingController _contactNumber = TextEditingController();
  final UserDBHelper _dbHelper = UserDBHelper.instance;

  bool _isButtonEnabled = false;

  late Size _size;

  @override
  void initState() {
    super.initState();
    _contactName.addListener(_checkFields);
    _contactNumber.addListener(_checkFields);

    if (widget.contact != null) {
      _contactName.text = widget.contact!.name;
      _contactNumber.text = widget.contact!.phoneNumber;
    }
  }

  void _checkFields() {
    setState(() {
      _isButtonEnabled = _contactName.text.isNotEmpty && _contactNumber.text.isNotEmpty;
    });
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      String contactName = _contactName.text;
      String contactNumber = _contactNumber.text;

      if (widget.isLocalContact) {
        await _updateLocalContact(contactName, contactNumber);
      } else {
        if (widget.contact == null) {
          ContactModel newContact = ContactModel(
            name: contactName,
            phoneNumber: contactNumber,
            isFromDevice: false,
          );
          await _dbHelper.insertContact(newContact, widget.userId);
        } else {
          ContactModel updatedContact = ContactModel(
            id: widget.contact!.id,
            name: contactName,
            phoneNumber: contactNumber,
            isFromDevice: widget.contact!.isFromDevice,
          );
          await _dbHelper.updateContact(updatedContact);
        }
      }
      widget.onSave();
    }
  }

  Future<void> _updateLocalContact(String name, String phoneNumber) async {
    if (widget.contact == null || widget.contact!.originalContact == null) return;

    try {
      Contact originalContact = widget.contact!.originalContact!;
      
      if (originalContact.phones != null && originalContact.phones!.isNotEmpty) {
        originalContact.phones!.first.value = phoneNumber;
      } else {
        originalContact.phones = [Item(label: 'mobile', value: phoneNumber)];
      }

      originalContact.displayName = name;
      await ContactsService.updateContact(originalContact);
    } catch (e) {
      print('Error actualizando el contacto local: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          width: _size.width,
          padding: const EdgeInsets.all(18),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.contact == null ? Icons.person_add_alt_1_outlined : Icons.person_pin_rounded,
                  size: 50,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    widget.contact == null ? 'Nuevo Contacto' : 'Editar Contacto',
                    textAlign: TextAlign.left,
                    style: AppConstants.titleStyle,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextFormField(
                  title: 'Nombre de contacto',
                  placeholder: 'Ingresa el nombre de contacto',
                  controller: _contactName,
                  keyboardType: TextInputType.name,
                  validator: validateUsername,
                  textColor: AppConstants.primaryColorDark,
                  prefixIcon: Icons.person,
                ),
                const SizedBox(height: 12),
                CustomTextFormField(
                  title: 'Número de Teléfono',
                  placeholder: '07 12 34 56 78',
                  controller: _contactNumber,
                  keyboardType: TextInputType.phone,
                  validator: validatePhoneNumber,
                  textColor: AppConstants.primaryColorDark,
                  prefixIcon: Icons.phone,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomElevatedButton(
                      text: "Cancelar",
                      backgroundColor: AppConstants.lightGrey,
                      textColor: AppConstants.primaryColorDark,
                      width: 150,
                      onPressed: widget.onCancel,
                    ),
                    CustomElevatedButton(
                      text: "Guardar",
                      backgroundColor: AppConstants.buttonColor,
                      textColor: AppConstants.primaryColorDark,
                      width: 150,
                      onPressed: _isButtonEnabled ? _saveContact : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
