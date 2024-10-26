import 'package:contacts_service/contacts_service.dart';

class ContactModel {
  final int? id;
  final String name;
  final String phoneNumber;
  final bool isFromDevice;
  final Contact? originalContact;

  ContactModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    this.isFromDevice = false,
    this.originalContact,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'isFromDevice': isFromDevice ? 1 : 0,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      isFromDevice: map['isFromDevice'] == 1,
    );
  }
}
