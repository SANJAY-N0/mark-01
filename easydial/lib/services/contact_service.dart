import 'dart:typed_data';

import 'package:flutter_contacts/flutter_contacts.dart';

import '../utils/phone_utils.dart';

enum PickStatus { picked, cancelled, denied, noPhone }

class PickedContact {
  final String? id;
  final String name;
  final String phone;
  final Uint8List? photo;

  const PickedContact({this.id, required this.name, required this.phone, this.photo});
}

class PickOutcome {
  final PickStatus status;
  final PickedContact? contact;

  const PickOutcome(this.status, [this.contact]);
}

class ContactService {
  /// Opens the phone's contact picker. Read permission is requested only at
  /// the moment the user chooses to pick from contacts.
  Future<PickOutcome> pickFromAddressBook() async {
    final granted = await FlutterContacts.requestPermission(readonly: true);
    if (!granted) return const PickOutcome(PickStatus.denied);

    final chosen = await FlutterContacts.openExternalPick();
    final id = chosen?.id;
    if (id == null) return const PickOutcome(PickStatus.cancelled);

    final full = await FlutterContacts.getContact(
      id,
      withProperties: true,
      withPhoto: true,
    );
    if (full == null) return const PickOutcome(PickStatus.cancelled);

    final numbers = full.phones
        .map((p) => p.number.trim())
        .where((n) => n.isNotEmpty)
        .toList();
    if (numbers.isEmpty) return const PickOutcome(PickStatus.noPhone);

    // Prefer a number that passes validation; otherwise take the first one
    // so the user can see it and correct it on the form.
    final phone = numbers.firstWhere(
      (n) => validatePhoneNumber(n) == null,
      orElse: () => numbers.first,
    );

    final displayName = full.displayName.trim();
    return PickOutcome(
      PickStatus.picked,
      PickedContact(
        id: full.id,
        name: displayName.isEmpty ? phone : displayName,
        phone: phone,
        photo: full.photo,
      ),
    );
  }
}
