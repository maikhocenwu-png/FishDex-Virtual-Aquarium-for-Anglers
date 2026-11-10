import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'add_catch_screen.dart';
import 'share_screen.dart';

/// A.5 Catch details
class CatchDetailsScreen extends StatelessWidget {
  const CatchDetailsScreen({super.key, required this.catchId});

  final String catchId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final matches = store.catches.where((c) => c.id == catchId);
        if (matches.isEmpty) {
          return const Scaffold(body: Center(child: Text('Catch not found')));
        }
        final c = matches.first;
        return Scaffold(
          body: Column(
            children: [
              const TopBar(title: 'Catch details', back: '<'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    PhotoBox(
                      height: 180,
                      label: c.hasPhoto ? 'PHOTO' : 'NO PHOTO',
                    ),
                    const SizedBox(height: 14),
                    Text(
                      c.species,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (c.fed) const Tag('Fed'),
                        Tag(c.uploaded ? 'Uploaded' : 'Waiting to upload'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    InfoRow(title: 'Caught', subtitle: fmtDateTime(c.caughtAt)),
                    const SizedBox(height: 8),
                    InfoRow(
                      title: 'Place',
                      subtitle: c.place.isEmpty ? 'Not given' : c.place,
                    ),
                    const SizedBox(height: 8),
                    InfoRow(title: 'Size', subtitle: c.sizeText),
                    const SizedBox(height: 8),
                    InfoRow(
                      title: 'Notes',
                      subtitle: c.notes.isEmpty ? 'None' : c.notes,
                    ),
                    const SizedBox(height: 20),
                    DarkButton(
                      'Edit catch',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AddCatchScreen(editing: c),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    OutlinePill(
                      'Share',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ShareScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
