import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'catch_details_screen.dart';

/// A.6 Map. For the demo the map is a drawn placeholder with pins.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  String? _selected;

  static const _spots = [
    Offset(0.30, 0.25),
    Offset(0.65, 0.40),
    Offset(0.45, 0.70),
    Offset(0.78, 0.78),
    Offset(0.20, 0.60),
  ];

  @override
  Widget build(BuildContext context) {
    final withPlace = store.catches.where((c) => c.place.isNotEmpty).toList();
    final selected =
        withPlace.where((c) => c.id == _selected).cast<CatchItem?>().firstOrNull;
    return Scaffold(
      body: Column(
        children: [
          const TopBar(title: 'Map', back: '<'),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEDED),
                border: Border.all(color: kLine),
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, box) {
                  return Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _GridPainter()),
                      ),
                      for (var i = 0; i < withPlace.length; i++)
                        Positioned(
                          left: _spots[i % _spots.length].dx * box.maxWidth - 16,
                          top: _spots[i % _spots.length].dy * box.maxHeight - 32,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selected = withPlace[i].id),
                            child: Icon(
                              Icons.location_on,
                              size: 36,
                              color: withPlace[i].id == _selected
                                  ? kInk
                                  : kDark.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                      const Positioned(
                        right: 8,
                        bottom: 6,
                        child: Text('Map placeholder',
                            style: TextStyle(fontSize: 11, color: kMuted)),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: selected == null
                ? const InfoRow(
                    title: 'Tap a pin',
                    subtitle: 'See which fish you caught there',
                  )
                : InfoRow(
                    title: selected.species,
                    subtitle: selected.subtitle,
                    trailing: const Text('>', style: TextStyle(fontSize: 18)),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CatchDetailsScreen(catchId: selected.id),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFD0D0D0)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    final river = Paint()
      ..color = const Color(0xFFC4C4C4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    final path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.55, size.width,
          size.height * 0.35);
    canvas.drawPath(path, river);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
