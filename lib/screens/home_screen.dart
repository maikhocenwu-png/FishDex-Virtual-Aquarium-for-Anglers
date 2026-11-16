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
        return RefreshIndicator(
          onRefresh: store.loadAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (store.loading) const LinearProgressIndicator(),
              if (store.error != null) ...[
                Text(
                  store.error!,
                  style: const TextStyle(color: Color(0xFFB00020)),
                ),
                const SizedBox(height: 8),
                OutlinePill(
                  'Reload',
                  height: 40,
                  fontSize: 14,
                  onTap: store.loadAll,
                ),
                const SizedBox(height: 12),
              ],
              DarkButton(
                '+ Add a catch',
                onTap: () => open(const AddCatchScreen()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinePill(
                      'Map',
                      height: 40,
                      fontSize: 14,
                      onTap: () => open(const MapScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinePill(
                      'Compare',
                      height: 40,
                      fontSize: 14,
                      onTap: () => open(const CompareScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '${items.length} catches',
                style: const TextStyle(fontSize: 12, color: kMuted),
              ),
              const SizedBox(height: 8),
              for (final c in items) ...[
                CatchCard(
                  title: c.species,
                  subtitle: c.subtitle,
                  tag: c.uploaded ? null : 'Waiting to upload',
                  species: c.species,
                  onTap: () => open(CatchDetailsScreen(catchId: c.id)),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AquariumTab extends StatelessWidget {
  const _AquariumTab({required this.open});

  final void Function(Widget screen) open;

  static const _fishWidth = 96.0;

  // Fixed spot for each fish: left and right columns, stacked down the tank.
  Widget _fishAt(CatchItem c, int i, double w, double h) {
    final row = i ~/ 2;
    final left = i.isEven ? 12.0 : (w - _fishWidth - 12);
    final top = (0.05 + (row % 4) * 0.19 + (i.isOdd ? 0.09 : 0)) * h;
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => open(CatchDetailsScreen(catchId: c.id)),
        child: Column(
          children: [
            // Right-column fish face left, so the tank looks natural.
            Transform.flip(
              flipX: i.isOdd,
              child: FishShape(species: c.species, width: _fishWidth),
            ),
            const SizedBox(height: 2),
            Text(
              c.species,
              style: const TextStyle(
                fontSize: 11,
                color: kInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFBFE6F5), Color(0xFF4AA3C7)],
                  ),
                  border: Border.all(color: kLine),
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, box) {
                    final w = box.maxWidth;
                    final h = box.maxHeight;
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(painter: _TankPainter()),
                        ),
                        for (var i = 0; i < fish.length; i++)
                          _fishAt(fish[i], i, w, h),
                        if (fish.isEmpty)
                          const Center(
                            child: Text(
                              'No fish yet.\nAdd a catch to fill your aquarium.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: kInk),
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
                  OutlinePill(
                    'Share',
                    width: 110,
                    height: 40,
                    fontSize: 14,
                    onTap: () => open(const ShareScreen()),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The still scenery: sand on the bottom and a few seaweed plants.
class _TankPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 26, size.width, 26),
      Paint()..color = const Color(0xFFE9D9A6),
    );

    final weed = Paint()
      ..color = const Color(0xFF3E9B5A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final fx in const [0.1, 0.45, 0.8]) {
      final x = size.width * fx;
      final p = Path()
        ..moveTo(x, size.height - 24)
        ..quadraticBezierTo(x + 8, size.height - 44, x, size.height - 62);
      canvas.drawPath(p, weed);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
