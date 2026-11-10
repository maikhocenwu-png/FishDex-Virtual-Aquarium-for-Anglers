import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// A.4 Species picker. Pops with the chosen species name.
class SpeciesPickerScreen extends StatefulWidget {
  const SpeciesPickerScreen({super.key});

  @override
  State<SpeciesPickerScreen> createState() => _SpeciesPickerScreenState();
}

class _SpeciesPickerScreenState extends State<SpeciesPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.toLowerCase();
    final list = kSpecies
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            (s.latin ?? '').toLowerCase().contains(q))
        .toList();
    return Scaffold(
      body: Column(
        children: [
          const TopBar(title: 'Choose species', back: '<'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: AppField(
              hint: 'Search species',
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final s = list[i];
                return InfoRow(
                  title: s.name,
                  subtitle: s.latin,
                  italicSubtitle: true,
                  trailing: s.habitat == 'unknown' ? null : Tag(s.habitat),
                  onTap: () => Navigator.of(context).pop(s.name),
                );
              },
            ),
          ),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No match. Pick "Unidentified / Other".',
                  style: TextStyle(color: kMuted)),
            ),
        ],
      ),
    );
  }
}
