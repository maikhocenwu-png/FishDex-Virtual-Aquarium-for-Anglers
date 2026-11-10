import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'add_catch_screen.dart';
import 'catch_details_screen.dart';
import 'compare_screen.dart';
import 'map_screen.dart';
import 'profile_screen.dart';
import 'share_screen.dart';

/// A.2 My catches + A.8 Aquarium, switched by the bottom tab bar.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: homeTab,
      builder: (context, tab, _) {
        return Scaffold(
          body: Column(
            children: [
              TopBar(
                title: tab == 0 ? 'My catches' : 'My aquarium',
                trailing: GestureDetector(
                  onTap: () => _open(context, const ProfileScreen()),
                  child: const Text(
                    'Profile',
                    style: TextStyle(fontSize: 16, color: kInk),
                  ),
                ),
              ),
              Expanded(
                child: tab == 0
                    ? _CatchesTab(open: (s) => _open(context, s))
                    : _AquariumTab(open: (s) => _open(context, s)),
              ),
            ],
          ),
          bottomNavigationBar: BottomTabs(
            index: tab,
            onChanged: (i) => homeTab.value = i,
          ),
        );
      },
    );
  }
}

class _CatchesTab extends StatelessWidget {
  const _CatchesTab({required this.open});

  final void Function(Widget screen) open;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final items = store.catches;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DarkButton('+ Add a catch',
                onTap: () => open(const AddCatchScreen())),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinePill('Map',
                      height: 40,
                      fontSize: 14,
                      onTap: () => open(const MapScreen())),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinePill('Compare',
                      height: 40,
                      fontSize: 14,
                      onTap: () => open(const CompareScreen())),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('${items.length} catches',
                style: const TextStyle(fontSize: 12, color: kMuted)),
            const SizedBox(height: 8),
            for (final c in items) ...[
              CatchCard(
                title: c.species,
                subtitle: c.subtitle,
                tag: c.uploaded ? null : 'Waiting to upload',
                onTap: () => open(CatchDetailsScreen(catchId: c.id)),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _AquariumTab extends StatelessWidget {
  const _AquariumTab({required this.open});

  final void Function(Widget screen) open;

  static const _shades = [
    Color(0xFF666666),
    Color(0xFF8A8A8A),
    Color(0xFF4F4F4F),
    Color(0xFFA0A0A0),
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final fish = store.catches.where((c) => c.fed).toList();
        return Column(
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  border: Border.all(color: kLine),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LayoutBuilder(
                  builder: (context, box) {
                    final w = box.maxWidth;
                    final h = box.maxHeight;
                    return Stack(
                      children: [
                        for (var i = 0; i < fish.length; i++)
                          Positioned(
                            left: (i.isEven ? 0.08 : 0.42) * w,
                            top: (0.08 + i * 0.2) * h,
                            child: GestureDetector(
                              onTap: () => open(
                                CatchDetailsScreen(catchId: fish[i].id),
                              ),
                              child: Column(
                                children: [
                                  FishShape(color: _shades[i % _shades.length]),
                                  const SizedBox(height: 4),
                                  Text(
                                    fish[i].species,
                                    style: const TextStyle(
                                        fontSize: 11, color: kInk),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (fish.isEmpty)
                          const Center(
                            child: Text(
                              'No fish yet.\nAdd a catch to fill your aquarium.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: kMuted),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${fish.length} fish in your aquarium',
                      style: const TextStyle(fontSize: 13, color: kMuted),
                    ),
                  ),
                  OutlinePill('Share',
                      width: 110,
                      height: 40,
                      fontSize: 14,
                      onTap: () => open(const ShareScreen())),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
