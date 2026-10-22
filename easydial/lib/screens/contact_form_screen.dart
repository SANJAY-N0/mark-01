import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/favourite.dart';
import '../services/contact_service.dart';
import '../services/favourites_repository.dart';
import '../utils/phone_utils.dart';
import '../widgets/common_widgets.dart';
import '../widgets/contact_avatar.dart';

/// Add a new favourite (no [existing]) or edit one.
/// Pops with the resulting [Favourite], or null if cancelled.
/// Photo files are written only when Save is pressed, so cancelling leaves no clutter.
class ContactFormScreen extends StatefulWidget {
  final Favourite? existing;

  const ContactFormScreen({super.key, this.existing});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = FavouritesRepository();
  final _contactService = ContactService();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  String? _savedPhotoPath;
  Uint8List? _newPhotoBytes;
  String? _contactId;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    _phoneCtrl = TextEditingController(text: existing?.phone ?? '');
    _savedPhotoPath = existing?.photoPath;
    _contactId = existing?.contactId;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFromContacts() async {
    final outcome = await _contactService.pickFromAddressBook();
    if (!mounted) return;

    switch (outcome.status) {
      case PickStatus.cancelled:
        return;
      case PickStatus.denied:
        await showInfoDialog(
          context,
          'Contacts access needed',
          'EasyDial needs permission to read your contacts so it can fill in '
              'the name and number for you. You can type the details in instead.',
        );
        return;
      case PickStatus.noPhone:
        await showInfoDialog(
          context,
          'No phone number',
          'That contact does not have a phone number saved. Please type a '
              'number in instead.',
        );
        return;
      case PickStatus.picked:
        final picked = outcome.contact!;
        setState(() {
          _nameCtrl.text = picked.name;
          _phoneCtrl.text = picked.phone;
          _contactId = picked.id;
          if (picked.photo != null) {
            _newPhotoBytes = picked.photo;
          }
        });
    }
  }

  Future<void> _choosePhoto() async {
    try {
      final file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      setState(() {
        _newPhotoBytes = bytes;
      });
    } catch (_) {
      if (!mounted) return;
      await showInfoDialog(
        context,
        'Photo not available',
        'EasyDial could not open your photo library. Please check the photo '
            'permission in your phone settings.',
      );
    }
  }

  void _removePhoto() {
    setState(() {
      _newPhotoBytes = null;
      _savedPhotoPath = null;
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);

    try {
      String? photoPath = _savedPhotoPath;
      if (_newPhotoBytes != null) {
        photoPath = await _repo.savePhoto(_newPhotoBytes!);
      }

      final favourite = Favourite(
        id: widget.existing?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        photoPath: photoPath,
        contactId: _contactId,
      );

      if (!mounted) return;
      Navigator.pop(context, favourite);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      await showInfoDialog(
        context,
        'Could not save',
        'Something went wrong while saving. Please try again.',
      );
    }
  }

  InputDecoration _fieldDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(fontSize: 20),
      hintStyle: const TextStyle(fontSize: 18),
      errorStyle: const TextStyle(fontSize: 18),
      border: const OutlineInputBorder(),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = _newPhotoBytes != null || _savedPhotoPath != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Contact' : 'Add Favourite Contact'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              BigButton(
                label: 'Choose from Contacts',
                icon: Icons.contacts,
                outlined: true,
                onPressed: _saving ? null : _pickFromContacts,
              ),
              const SizedBox(height: 8),
              const Text(
                'Or type the details below.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameCtrl,
                style: const TextStyle(fontSize: 22),
                textCapitalization: TextCapitalization.words,
                decoration: _fieldDecoration('Name', 'For example, Mary Smith'),
                onChanged: (_) => setState(() {}),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Please enter a name.' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneCtrl,
                style: const TextStyle(fontSize: 22),
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration('Phone number', 'For example, 555 010 1234'),
                validator: validatePhoneNumber,
              ),
              const SizedBox(height: 28),
              Center(
                child: ContactAvatar(
                  name: _nameCtrl.text,
                  photoPath: _savedPhotoPath,
                  photoBytes: _newPhotoBytes,
                  size: 150,
                ),
              ),
              const SizedBox(height: 12),
              BigButton(
                label: 'Choose Photo',
                icon: Icons.photo_library,
                outlined: true,
                onPressed: _saving ? null : _choosePhoto,
              ),
              if (hasPhoto)
                TextButton(
                  onPressed: _saving ? null : _removePhoto,
                  child: const Text('Remove photo', style: TextStyle(fontSize: 18)),
                ),
              const SizedBox(height: 28),
              BigButton(
                label: 'Save Contact',
                icon: Icons.check,
                onPressed: _saving ? null : _save,
              ),
              const SizedBox(height: 12),
              BigButton(
                label: 'Cancel',
                icon: Icons.close,
                outlined: true,
                onPressed: _saving ? null : () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
