import 'package:flutter/material.dart';

import '../models/favourite.dart';
import 'contact_avatar.dart';

/// A large, fully tappable tile for a saved favourite.
class ContactTile extends StatelessWidget {
  final Favourite favourite;
  final VoidCallback onTap;

  const ContactTile({super.key, required this.favourite, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: 'Call ${favourite.name}',
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: scheme.primary, width: 2),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final avatarSize = (constraints.maxWidth * 0.6).clamp(64.0, 120.0).toDouble();
                // FittedBox scales the content down rather than overflowing
                // if the user has set a very large system text size.
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ContactAvatar(
                          name: favourite.name,
                          photoPath: favourite.photoPath,
                          size: avatarSize,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          favourite.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.phone, size: 20, color: scheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Tap to call',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// A large grey tile that opens the add-contact screen.
class EmptySlotTile extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const EmptySlotTile({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(color: scheme.primary, shape: BoxShape.circle),
                    child: const Icon(Icons.add, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
