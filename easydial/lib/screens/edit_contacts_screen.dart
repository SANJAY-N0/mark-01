import 'package:flutter/material.dart';

import '../models/favourite.dart';
import '../services/favourites_repository.dart';
import '../widgets/common_widgets.dart';
import '../widgets/contact_avatar.dart';
import 'contact_form_screen.dart';

class EditContactsScreen extends StatefulWidget {
  const EditContactsScreen({super.key});

  @override
  State<EditContactsScreen> createState() => _EditContactsScreenState();
}

class _EditContactsScreenState extends State<EditContactsScreen> {
  final _repo = FavouritesRepository();

  List<Favourite> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await _repo.load();
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  // Changes are saved as they are made, so nothing is lost if the app closes.
  Future<void> _save() => _repo.save(_items);

  Future<void> _addContact() async {
    if (_items.length >= FavouritesRepository.maxFavourites) return;
    final created = await Navigator.push<Favourite>(
      context,
      MaterialPageRoute(builder: (_) => const ContactFormScreen()),
    );
    if (created == null || !mounted) return;
    setState(() => _items.add(created));
    await _save();
  }

  Future<void> _editContact(int index) async {
    final original = _items[index];
    final updated = await Navigator.push<Favourite>(
      context,
      MaterialPageRoute(builder: (_) => ContactFormScreen(existing: original)),
    );
    if (updated == null || !mounted) return;

    if (original.photoPath != updated.photoPath) {
      await _repo.deletePhoto(original.photoPath);
    }
    setState(() => _items[index] = updated);
    await _save();
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _items.length) return;
    setState(() {
      final item = _items.removeAt(index);
      _items.insert(target, item);
    });
    _save();
  }

  Future<void> _removeContact(int index) async {
    final favourite = _items[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Remove ${favourite.name}?',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "This only removes them from EasyDial. They will stay in your phone's contacts.",
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Remove',
              style: TextStyle(fontSize: 20, color: Color(0xFFB00020), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _items.removeAt(index));
    await _repo.deletePhoto(favourite.photoPath);
    await _save();
  }

  Future<void> _removeSamples() async {
    final samples = _items.where((f) => f.isSample).toList();
    setState(() => _items.removeWhere((f) => f.isSample));
    for (final sample in samples) {
      await _repo.deletePhoto(sample.photoPath);
    }
    await _save();
  }

  Widget _actionButton(String label, IconData icon, VoidCallback? onPressed) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 22),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 56),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
    );
  }

  Widget _filledCard(int index) {
    final favourite = _items[index];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ContactAvatar(
                  name: favourite.name,
                  photoPath: favourite.photoPath,
                  size: 72,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${favourite.name}',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        favourite.phone.isEmpty ? 'No number yet' : favourite.phone,
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _actionButton('Edit', Icons.edit, () => _editContact(index)),
                _actionButton(
                  'Move up',
                  Icons.arrow_upward,
                  index > 0 ? () => _move(index, -1) : null,
                ),
                _actionButton(
                  'Move down',
                  Icons.arrow_downward,
                  index < _items.length - 1 ? () => _move(index, 1) : null,
                ),
                _actionButton('Remove', Icons.delete_outline, () => _removeContact(index)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard() {
    return Card(
      color: const Color(0xFFE5E7EB),
      child: InkWell(
        onTap: _addContact,
        child: const Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(Icons.add_circle, size: 40),
              SizedBox(width: 14),
              Text(
                'Add Contact',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasSamples = _items.any((f) => f.isSample);

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Contacts')),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BigButton(
            label: 'Done',
            icon: Icons.home,
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Up to six favourites appear on the Home screen. '
                  'Use Move up and Move down to change their order.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < FavouritesRepository.maxFavourites; i++) ...[
                  i < _items.length ? _filledCard(i) : _emptyCard(),
                  const SizedBox(height: 14),
                ],
                if (hasSamples) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _removeSamples,
                    icon: const Icon(Icons.cleaning_services, size: 22),
                    label: const Text(
                      'Remove sample contacts',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 56)),
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
