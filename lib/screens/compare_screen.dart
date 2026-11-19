import 'package:material_ui/material_ui.dart';

import '../data/store.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'catch_details_screen.dart';

/// A.7 Compare: pick two or more of your own catches (same or different
/// species) and see them side by side.
class CompareScreen extends StatefulWidget {
  const CompareScreen({super.key});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  String? _filter; // species chip used to narrow the list (null = all)
  final Set<String> _picked = {}; // ids of the catches ticked for comparing

  static String _num(double v) =>
      v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

  static String _cm(double v) => '${_num(v)} cm';

  static String _kg(double v) =>
      '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(2)} kg';

  static String _day(DateTime d) => '${fmtDate(d)}, ${d.year}';

  /// freshwater / saltwater / brackish, from the species list.
  static String _habitatOf(String name) {
    for (final s in store.species) {
      if (s.name == name) {
        final h = s.habitat;
        return h == 'unknown' ? '-' : '${h[0].toUpperCase()}${h.substring(1)}';
      }
    }
    return '-';
  }

  static double? _maxOf(List<double?> values) {
    double? best;
    for (final v in values) {
      if (v != null && (best == null || v > best)) {
        best = v;
      }
    }
    return best;
  }

  Widget _cell(String text, {bool bold = false, Color color = kInk}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }

  /// The side-by-side table: one column per ticked catch.
  Widget _table(BuildContext context, List<CatchItem> chosen) {
    final lens = [for (final c in chosen) double.tryParse(c.length)];
    final wts = [for (final c in chosen) double.tryParse(c.weight)];
    final maxLen = _maxOf(lens);
    final maxWt = _maxOf(wts);

    // Stretch the columns to fill the box (no empty strip on the right).
    // With many catches they stay 112 wide and the table scrolls sideways.
    final avail = MediaQuery.of(context).size.width - 34; // padding + border
    final fit = (avail - 92) / chosen.length;
    final colW = fit > 112 ? fit : 112.0;

    final widths = <int, TableColumnWidth>{0: const FixedColumnWidth(92)};
    for (var i = 0; i < chosen.length; i++) {
      widths[i + 1] = FixedColumnWidth(colW);
    }

    // Every second row is lightly shaded so the rows are easy to follow.
    var rowNo = 0;
    TableRow row(String label, List<Widget> cells) {
      rowNo++;
      return TableRow(
        decoration: rowNo.isOdd
            ? null
            : const BoxDecoration(color: Color(0xFFF7F7F7)),
        children: [_cell(label, color: kMuted), ...cells],
      );
    }

    // Header: the species of each catch; tap it to open that catch.
    final header = TableRow(
      decoration: const BoxDecoration(color: kBar),
      children: [
        _cell(''),
        for (final c in chosen)
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CatchDetailsScreen(catchId: c.id),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Text(
                c.species,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kInk,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
      ],
    );

    final scroller = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        columnWidths: widths,
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        border: const TableBorder(
          horizontalInside: BorderSide(color: kTag),
          verticalInside: BorderSide(color: kTag),
        ),
        children: [
          header,
          row('Habitat', [
            for (final c in chosen) _cell(_habitatOf(c.species)),
          ]),
          row('Date', [for (final c in chosen) _cell(_day(c.caughtAt))]),
          row('Time', [for (final c in chosen) _cell(fmtTime(c.caughtAt))]),
          row('Place', [
            for (final c in chosen) _cell(c.place.isEmpty ? '-' : c.place),
          ]),
          row('Length', [
            for (final l in lens)
              _cell(l == null ? '-' : _cm(l), bold: l != null && l == maxLen),
          ]),
          row('Length bar', [
            for (final l in lens)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: (l == null || maxLen == null || maxLen <= 0)
                    ? const SizedBox(height: 6)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Container(
                          height: 6,
                          color: kTag,
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: (l / maxLen)
                                .clamp(0.03, 1.0)
                                .toDouble(),
                            child: Container(color: kDark),
                          ),
                        ),
                      ),
              ),
          ]),
          row('vs biggest', [
            for (final l in lens)
              _cell(
                (l == null || maxLen == null)
                    ? '-'
                    : (l == maxLen ? 'Biggest' : '-${_cm(maxLen - l)}'),
                color: kMuted,
              ),
          ]),
          row('Weight', [
            for (final w in wts)
              _cell(w == null ? '-' : _kg(w), bold: w != null && w == maxWt),
          ]),
          row('vs heaviest', [
            for (final w in wts)
              _cell(
                (w == null || maxWt == null)
                    ? '-'
                    : (w == maxWt ? 'Heaviest' : '-${_kg(maxWt - w)}'),
                color: kMuted,
              ),
          ]),
        ],
      ),
    );

    // One rounded box around the whole table.
    // The border is drawn ON TOP (foregroundDecoration) so the grey header
    // cannot cover it at the rounded corners.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: kLine),
        borderRadius: BorderRadius.circular(8),
      ),
      child: scroller,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        // How many catches of each species, most caught first.
        final counts = <String, int>{};
        for (final c in store.catches) {
          counts[c.species] = (counts[c.species] ?? 0) + 1;
        }
        final names = counts.keys.toList()
          ..sort((a, b) {
            final d = counts[b]!.compareTo(counts[a]!);
            return d != 0 ? d : a.compareTo(b);
          });

        return Scaffold(
          body: Column(
            children: [
              const TopBar(title: 'Compare', back: '<'),
              Expanded(
                child: SafeArea(
                  top: false,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: names.isEmpty
                        ? [
                            const InfoRow(
                              title: 'Nothing to compare yet',
                              subtitle:
                                  'Save a few catches, then compare them here.',
                            ),
                          ]
                        : _content(context, counts, names),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _content(
    BuildContext context,
    Map<String, int> counts,
    List<String> names,
  ) {
    final filter = (_filter != null && counts.containsKey(_filter))
        ? _filter
        : null;

    // The list to tick from (narrowed by the chip), newest first.
    final list =
        store.catches
            .where((c) => filter == null || c.species == filter)
            .toList()
          ..sort((a, b) => b.caughtAt.compareTo(a.caughtAt));

    // Everything ticked, even if the chip now hides it, newest first.
    final chosen = [
      for (final c in store.catches)
        if (_picked.contains(c.id)) c,
    ]..sort((a, b) => b.caughtAt.compareTo(a.caughtAt));

    final allPicked =
        store.catches.isNotEmpty &&
        store.catches.every((c) => _picked.contains(c.id));
    final speciesPicked =
        list.isNotEmpty && list.every((c) => _picked.contains(c.id));

    final pill = OutlinedButton.styleFrom(
      foregroundColor: kInk,
      side: const BorderSide(color: kLine),
      visualDensity: VisualDensity.compact,
    );

    return [
      const FieldLabel('Show'),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ChoiceChip(
            label: Text('All (${store.catches.length})'),
            selected: filter == null,
            onSelected: (_) => setState(() => _filter = null),
          ),
          for (final n in names)
            ChoiceChip(
              label: Text('$n (${counts[n]})'),
              selected: n == filter,
              // tapping the chosen species again goes back to All
              onSelected: (_) =>
                  setState(() => _filter = (n == filter) ? null : n),
            ),
        ],
      ),
      const Divider(height: 32, color: kTag),
      Row(
        children: [
          const Expanded(
            child: Text(
              'Tick two or more catches',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kInk,
              ),
            ),
          ),
          Text(
            '${chosen.length} selected',
            style: const TextStyle(fontSize: 13, color: kMuted),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          // Ticks every catch you have; tap again to untick them all.
          OutlinedButton(
            style: pill,
            onPressed: () => setState(() {
              if (allPicked) {
                _picked.clear();
              } else {
                _picked.addAll(store.catches.map((c) => c.id));
              }
            }),
            child: Text(
              allPicked ? 'Unselect all catches' : 'Select all catches',
            ),
          ),
          // Only shown once a species chip is chosen.
          if (filter != null)
            OutlinedButton(
              style: pill,
              onPressed: () => setState(() {
                if (speciesPicked) {
                  _picked.removeAll(list.map((c) => c.id));
                } else {
                  _picked.addAll(list.map((c) => c.id));
                }
              }),
              child: Text(
                speciesPicked ? 'Unselect all $filter' : 'Select all $filter',
              ),
            ),
          if (chosen.isNotEmpty)
            OutlinedButton(
              style: pill,
              onPressed: () => setState(() => _picked.clear()),
              child: const Text('Clear'),
            ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          border: Border.all(color: kLine),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            for (var i = 0; i < list.length; i++) ...[
              if (i > 0) const Divider(height: 1, color: kTag),
              CheckboxListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                dense: true,
                controlAffinity: ListTileControlAffinity.leading,
                value: _picked.contains(list[i].id),
                onChanged: (on) => setState(() {
                  if (on == true) {
                    _picked.add(list[i].id);
                  } else {
                    _picked.remove(list[i].id);
                  }
                }),
                title: Text(
                  list[i].species,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text('${list[i].subtitle}  |  ${list[i].sizeText}'),
              ),
            ],
          ],
        ),
      ),
      const Divider(height: 32, color: kTag),
      if (chosen.length < 2)
        const InfoRow(
          title: 'Pick at least two catches',
          subtitle: 'They can be the same species or different ones.',
        )
      else ...[
        const FieldLabel('Side by side'),
        _table(context, chosen),
      ],
    ];
  }
}
