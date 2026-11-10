import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// A.9 Share preview. Shows what a friend would see, based on privacy switches.
class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final fish = store.catches.where((c) => c.fed).toList();
        return Scaffold(
          body: Column(
            children: [
              const TopBar(title: 'Share preview', back: '<'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text('This is what your friends will see',
                        style: TextStyle(fontSize: 13, color: kMuted)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        border: Border.all(color: kLine),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text('My FishDex aquarium',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: kInk)),
                          const SizedBox(height: 16),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 20,
                            runSpacing: 12,
                            children: [
                              for (final c in fish.take(4))
                                Column(
                                  children: [
                                    const FishShape(),
                                    const SizedBox(height: 4),
                                    Text(c.species,
                                        style: const TextStyle(fontSize: 11)),
                                  ],
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('${fish.length} fish',
                              style:
                                  const TextStyle(fontSize: 13, color: kMuted)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    InfoRow(
                      title: 'Location',
                      trailing: Tag(store.shareLocation ? 'Shown' : 'Hidden'),
                    ),
                    const SizedBox(height: 8),
                    InfoRow(
                      title: 'Photos',
                      trailing: Tag(store.sharePhotos ? 'Shown' : 'Hidden'),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Change these in Profile and privacy.',
                      style: TextStyle(fontSize: 12, color: kMuted),
                    ),
                    const SizedBox(height: 20),
                    DarkButton(
                      'Share',
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sharing arrives later in the project'),
                        ),
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
