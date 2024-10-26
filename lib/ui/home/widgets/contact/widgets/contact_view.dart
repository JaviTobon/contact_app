import 'package:contact_app/utils/theme/app_constants.dart';
import 'package:contact_app/utils/widgets/custom_elevated_button.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:contact_app/utils/db/db_helper.dart';
import 'package:contact_app/ui/home/widgets/contact/model/contact_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactView extends StatefulWidget {
  final int userId;
  final Function(ContactModel?, {bool isLocalContact}) onGoToContactForm;

  const ContactView({
    super.key,
    required this.userId,
    required this.onGoToContactForm,
  });

  @override
  State<ContactView> createState() => _ContactViewState();
}

class _ContactViewState extends State<ContactView> {
  List<ContactModel> _contacts = [];
  List<ContactModel> _filteredContacts = [];
  List<ContactModel> _localContacts = [];
  List<ContactModel> _filteredLocalContacts = [];

  bool _isLoading = true;
  bool _contactsPermissionGranted = false;
  bool _isLoadingLocalContacts = false;
  bool _isSearching = false;

  late Size _size;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _checkFirstContact();
  }

  Future<void> _loadContacts() async {
    final dbHelper = UserDBHelper.instance;
    final contacts = await dbHelper.getContactsForUser(widget.userId);

    setState(() {
      _contacts = contacts;
      _filteredContacts = contacts;
      _isLoading = false;
    });

    if (await Permission.contacts.isGranted) {
      setState(() {
        _contactsPermissionGranted = true;
      });
      _loadLocalContacts();
    }
  }

  Future<void> _checkFirstContact() async {
    final dbHelper = UserDBHelper.instance;
    final user = await dbHelper.getUserById(widget.userId);

    if (user != null && user.firstContact) {
      _requestContactsPermission();
      user.firstContact = false;
      await dbHelper.updateUser(user);
    }
  }

  Future<void> _requestContactsPermission() async {
    final status = await Permission.contacts.request();

    if (status.isGranted) {
      setState(() {
        _contactsPermissionGranted = true;
      });
      _loadLocalContacts();
    } else if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog<void>(
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
                        'Permiso de contactos denegado',
                        style: AppConstants.titleStyle,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Por favor, habilita los permisos de contactos desde los ajustes.',
                        textAlign: TextAlign.center,
                        style: AppConstants.bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomElevatedButton(
                            text: 'Cancelar',
                            backgroundColor: AppConstants.lightGrey,
                            textColor: AppConstants.primaryColorDark,
                            width: 140,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          CustomElevatedButton(
                            text: 'Abrir ajustes',
                            backgroundColor: AppConstants.secondaryColor,
                            textColor: AppConstants.primaryColorDark,
                            width: 140,
                            onPressed: () {
                              Navigator.of(context).pop();
                              openAppSettings();
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
      },
    );
  }

  Future<void> _loadLocalContacts() async {
    setState(() {
      _isLoadingLocalContacts = true;
    });

    try {
      Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);

      setState(() {
        _localContacts = contacts.map((contact) {
          final phoneNumber = contact.phones?.isNotEmpty == true
              ? contact.phones!.first.value
              : 'Sin número';
          return ContactModel(
            originalContact: contact,
            name: contact.displayName ?? 'Sin nombre',
            phoneNumber: phoneNumber ?? 'Sin número',
            isFromDevice: true,
          );
        }).toList();
        _filteredLocalContacts = _localContacts;
        _isLoadingLocalContacts = false;
      });
    } catch (e) {
      print('Error al cargar los contactos: $e');
      setState(() {
        _isLoadingLocalContacts = false;
      });
    }
  }

  void _filterContacts(String query) {
    if (query.length < 3) {
      setState(() {
        _filteredContacts = _contacts;
        _filteredLocalContacts = _localContacts;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      final searchLower = query.toLowerCase();

      _filteredContacts = _contacts.where((contact) {
        return contact.name.toLowerCase().contains(searchLower) ||
            contact.phoneNumber.toLowerCase().contains(searchLower);
      }).toList();

      _filteredLocalContacts = _localContacts.where((contact) {
        return contact.name.toLowerCase().contains(searchLower) ||
            contact.phoneNumber.toLowerCase().contains(searchLower);
      }).toList();
    });
  }

  void _deleteContact(ContactModel contact) async {
    final dbHelper = UserDBHelper.instance;
    await dbHelper.deleteContact(contact.id!, contact.isFromDevice);
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    _size = MediaQuery.of(context).size;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar contacto...',
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.search),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppConstants.lightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: AppConstants.lightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide:
                        const BorderSide(color: AppConstants.primaryColorDark),
                  ),
                ),
                onChanged: _filterContacts,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.person_add_alt_1_outlined),
              color: AppConstants.primaryColorDark,
              onPressed: () {
                widget.onGoToContactForm(null);
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildAccordion(),
      ],
    );
  }

  Widget _buildAccordion() {
    return SizedBox(
      width: _size.width,
      height: _size.height * 0.7,
      child: ListView(
        children: [
          ExpansionTile(
            title: const Text('Contactos de la aplicación'),
            children: _buildContactList(
                _isSearching ? _filteredContacts : _contacts,
                isLocal: false),
          ),
          ExpansionTile(
            title: const Text('Contactos locales'),
            children: _isLoadingLocalContacts
                ? [
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 12)
                  ]
                : _contactsPermissionGranted
                    ? _buildContactList(
                        _isSearching ? _filteredLocalContacts : _localContacts,
                        isLocal: true)
                    : [
                        const Center(
                          child: Text(
                            'No hay contactos locales disponibles',
                            style: AppConstants.infoTextStyle,
                          ),
                        ),
                        const SizedBox(height: 12),
                        CustomElevatedButton(
                          text: 'Cargar contactos',
                          backgroundColor: AppConstants.secondaryColor,
                          textColor: AppConstants.primaryColorDark,
                          width: 150,
                          onPressed: _requestContactsPermission,
                        ),
                        const SizedBox(height: 24),
                      ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContactList(List<ContactModel> contacts,
      {required bool isLocal}) {
    if (contacts.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Center(
            child: Text(
              'No existe el contacto',
              style: AppConstants.infoTextStyle,
            ),
          ),
        ),
      ];
    }

    return contacts.asMap().entries.map((entry) {
      int index = entry.key;
      ContactModel contact = entry.value;

      String contactKey = isLocal
          ? 'local-$index-${contact.phoneNumber}'
          : 'app-$index-${contact.id}';

      return Slidable(
        key: ValueKey(contactKey),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                widget.onGoToContactForm(contact, isLocalContact: isLocal);
              },
              backgroundColor: Colors.white,
              foregroundColor: AppConstants.secondaryColor,
              icon: Icons.edit,
            ),
            if (!isLocal)
              SlidableAction(
                onPressed: (context) {
                  _confirmDelete(contact);
                },
                backgroundColor: Colors.white,
                foregroundColor: AppConstants.errorColor,
                icon: Icons.delete,
              ),
          ],
        ),
        child: ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.phoneNumber),
        ),
      );
    }).toList();
  }

  void _confirmDelete(ContactModel contact) {
    showDialog<void>(
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
                        'Eliminar contacto',
                        style: AppConstants.titleStyle,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '¿Estás seguro de que deseas eliminar este contacto?',
                        textAlign: TextAlign.center,
                        style: AppConstants.bodyStyle,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomElevatedButton(
                            text: 'Cancelar',
                            backgroundColor: AppConstants.lightGrey,
                            textColor: AppConstants.primaryColorDark,
                            width: 140,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          CustomElevatedButton(
                            text: 'Aceptar',
                            backgroundColor: AppConstants.secondaryColor,
                            textColor: AppConstants.primaryColorDark,
                            width: 140,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _deleteContact(contact);
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
      },
    );
  }
}
