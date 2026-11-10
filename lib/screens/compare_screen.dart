import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// A.7 Compare. Friend numbers are sample data for the demo.
class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mine = store.catches;
    final species = mine.map((c) => c.species).toSet().length;
    var biggest = 0.0;
    for (final c in mine) {
      final v = double.tryParse(c.length) ?? 0;
      if (v > biggest) biggest = v;
    }

    Widget cell(String text, {bool bold = false}) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                  color: kInk,
                ),
              ),
            ),
          ),
        );

    Widget row(String label, String a, String b) => Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: kTag)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label,
                    style: const TextStyle(fontSize: 13, color: kMuted)),
              ),
              cell(a, bold: true),
              cell(b),
            ],
          ),
        );

    return Scaffold(
      body: Column(
        children: [
          const TopBar(title: 'Compare', back: '<'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const InfoRow(
                  title: 'Comparing with Jane Doe',
                  subtitle: 'Friends only see what they allow',
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    Expanded(flex: 2, child: SizedBox()),
                    Expanded(
                      child: Center(
                        child: Text('You',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text('Jane Doe',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                row('Total catches', '${mine.length}', '12'),
                row('Species', '$species', '7'),
                row('Biggest fish',
                    biggest == 0 ? '-' : '${biggest.toStringAsFixed(0)} cm',
                    '64 cm'),
                row('Fish in aquarium',
                    '${mine.where((c) => c.fed).length}', '11'),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: kLine),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Demo data: Jane Doe is a sample friend. Real comparing comes '
                    'later in the project.',
                    style: TextStyle(fontSize: 12, color: kMuted),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
