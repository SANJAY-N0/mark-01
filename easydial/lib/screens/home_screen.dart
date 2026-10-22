import 'package:flutter/material.dart';

import '../models/favourite.dart';
import '../services/dialer_service.dart';
import '../services/favourites_repository.dart';
import '../utils/phone_utils.dart';
import '../widgets/common_widgets.dart';
import '../widgets/contact_tiles.dart';
import 'contact_form_screen.dart';
import 'edit_contacts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repo = FavouritesRepository();
  final _dialer = DialerService();

  List<Favourite> _favourites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _repo.seedSamplesIfFirstRun();
    await _reload();
  }

  Future<void> _reload() async {
    final items = await _repo.load();
    if (!mounted) return;
    setState(() {
      _favourites = items;
      _loading = false;
    });
  }

  Future<void> _call(Favourite favourite) async {
    if (validatePhoneNumber(favourite.phone) != null) {
      await showInfoDialog(
        context,
        'No phone number',
        '${favourite.name} does not have a valid phone number yet.\n\n'
            'Please tap Edit Contacts to add the number.',
      );
      return;
    }

    final opened = await _dialer.openDialer(favourite.phone);
    if (!opened && mounted) {
      await showInfoDialog(
        context,
        'Dialler not available',
        'The phone dialler could not be opened. Please try again.',
      );
    }
  }

  Future<void> _addContact() async {
    if (_favourites.length >= FavouritesRepository.maxFavourites) return;

    final created = await Navigator.push<Favourite>(
      context,
      MaterialPageRoute(builder: (_) => const ContactFormScreen()),
    );
    if (created == null) return;

    final items = await _repo.load();
    if (items.length >= FavouritesRepository.maxFavourites) return;
    await _repo.save([...items, created]);
    await _reload();
  }

  Future<void> _openEditContacts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditContactsScreen()),
    );
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = !_loading && _favourites.isEmpty;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_in_talk, color: primary, size: 30),
            const SizedBox(width: 8),
            const Text('EasyDial'),
          ],
        ),
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    Text(
                      isEmpty ? 'Welcome to EasyDial' : 'Who would you like to call?',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isEmpty
                          ? 'Tap "Add Your First Contact" to choose a favourite person.'
                          : 'Tap a photo to open the dialler.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.78,
                        children: List.generate(FavouritesRepository.maxFavourites, (i) {
                          if (i < _favourites.length) {
                            final favourite = _favourites[i];
                            return ContactTile(
                              favourite: favourite,
                              onTap: () => _call(favourite),
                            );
                          }
                          return EmptySlotTile(
                            label: (isEmpty && i == 0) ? 'Add Your First Contact' : 'Add Contact',
                            onTap: _addContact,
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 12),
                    BigButton(
                      label: 'Edit Contacts',
                      icon: Icons.edit,
                      onPressed: _openEditContacts,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
