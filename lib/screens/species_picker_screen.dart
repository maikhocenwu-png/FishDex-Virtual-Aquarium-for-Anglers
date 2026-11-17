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
  void initState() {
    super.initState();
    // If the list is empty (the first load failed), try again when opening.
    if (store.species.isEmpty && !store.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => store.loadAll());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final q = _query.toLowerCase();
        final list = store.species
            .where(
              (s) =>
                  s.name.toLowerCase().contains(q) ||
                  (s.latin ?? '').toLowerCase().contains(q),
            )
            .toList();
        return Scaffold(
          body: Column(
            children: [
              const TopBar(title: 'Choose species', back: '<'),
              if (store.loading) const LinearProgressIndicator(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: AppField(
                  hint: 'Search species',
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
              if (store.species.isEmpty && !store.loading)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Loaded ${store.species.length} species.\n'
                        '${store.error ?? 'No error reported.'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: kMuted),
                      ),
                      const SizedBox(height: 12),
                      OutlinePill(
                        'Try again',
                        width: 160,
                        onTap: store.loadAll,
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: SafeArea(top: false, child: ListView.separated(
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
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}
