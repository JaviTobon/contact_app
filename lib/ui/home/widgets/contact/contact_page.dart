import 'package:contact_app/ui/home/widgets/contact/model/contact_model.dart';
import 'package:contact_app/ui/home/widgets/contact/widgets/contact_form.dart';
import 'package:contact_app/ui/home/widgets/contact/widgets/contact_view.dart';
import 'package:flutter/material.dart';
import 'package:contact_app/ui/home/widgets/user_profile/model/user_model.dart';

class ContactPage extends StatefulWidget {
  final UserModel user;

  const ContactPage({
    super.key,
    required this.user,
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  bool _isAddingContact = false;
  ContactModel? _contactToEdit;
  bool _isLocalContact = false;

  void _toggleContactForm({ContactModel? contact, bool isLocalContact = false}) {
    setState(() {
      _isAddingContact = !_isAddingContact;
      _contactToEdit = contact;
      _isLocalContact = isLocalContact;
    });
  }

  void _reloadContacts() {
    setState(() {
      _isAddingContact = false;
      _contactToEdit = null;
      _isLocalContact = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isAddingContact
              ? ContactForm(
                  userId: widget.user.id!,
                  onCancel: _toggleContactForm,
                  onSave: _reloadContacts,
                  contact: _contactToEdit,
                  isLocalContact: _isLocalContact,
                )
              : Column(
                  children: [
                    ContactView(
                      userId: widget.user.id!,
                      onGoToContactForm: (contact, {bool isLocalContact = false}) {
                        _toggleContactForm(contact: contact, isLocalContact: isLocalContact);
                      },
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
