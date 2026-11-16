import 'package:flutter/material.dart';

import '../data/store.dart';
import '../ui/widgets.dart';
import 'species_picker_screen.dart';

// this screen is used to add a new catch or edit an existing one.
class AddCatchScreen extends StatefulWidget {
  const AddCatchScreen({super.key, this.editing});

  final CatchItem? editing;

  @override
  State<AddCatchScreen> createState() => _AddCatchScreenState();
}

class _AddCatchScreenState extends State<AddCatchScreen> {
  late String? _species;
  late DateTime _when;
  late bool _hasPhoto;
  bool _saving = false;
  late final TextEditingController _place;
  late final TextEditingController _length;
  late final TextEditingController _weight;
  late final TextEditingController _notes;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _species = e?.species;
    _when = e?.caughtAt ?? DateTime.now();
    _hasPhoto = e?.hasPhoto ?? false;
    _place = TextEditingController(text: e?.place ?? '');
    _length = TextEditingController(text: e?.length ?? '');
    _weight = TextEditingController(text: e?.weight ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _place.dispose();
    _length.dispose();
    _weight.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickSpecies() async {
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const SpeciesPickerScreen()),
    );
    if (picked != null) setState(() => _species = picked);
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _when,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) {
      setState(() {
        _when = DateTime(d.year, d.month, d.day, _when.hour, _when.minute);
      });
    }
  }

  Future<void> _save() async {
    if (_species == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a species first')),
      );
      return;
    }
    setState(() => _saving = true);
    final e = widget.editing;
    try {
      if (e != null) {
        e.species = _species!;
        e.caughtAt = _when;
        e.place = _place.text.trim();
        e.length = _length.text.trim();
        e.weight = _weight.text.trim();
        e.notes = _notes.text.trim();
        e.hasPhoto = _hasPhoto;
        await store.updateCatch(e);
      } else {
        await store.addCatch(
          CatchItem(
            id: newCatchId(),
            species: _species!,
            caughtAt: _when,
            place: _place.text.trim(),
            length: _length.text.trim(),
            weight: _weight.text.trim(),
            notes: _notes.text.trim(),
            hasPhoto: _hasPhoto,
          ),
        );
        homeTab.value = 0;
      }
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Changes saved'
                : 'Saved. A new fish joined your aquarium!',
          ),
        ),
      );
    } catch (_) {
      store.loadAll(); // put the screen back to what is really saved
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not save. Check your internet. Length and weight must be above 0.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TopBar(title: _isEdit ? 'Edit catch' : 'Add a catch', back: 'Cancel'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _hasPhoto = !_hasPhoto),
                    child: PhotoBox(
                      height: 150,
                      label: _hasPhoto ? 'PHOTO ADDED' : 'TAP TO ADD PHOTO',
                    ),
                  ),
                  const FieldLabel('Species'),
                  PickField(
                    _species ?? 'Choose a species',
                    placeholder: _species == null,
                    onTap: _pickSpecies,
                  ),
                  const FieldLabel('Date and time'),
                  PickField(fmtDateTime(_when), onTap: _pickDate),
                  const FieldLabel('Place'),
                  AppField(controller: _place, hint: 'Where did you catch it?'),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FieldLabel('Length (cm)'),
                            AppField(
                              controller: _length,
                              hint: 'e.g. 38',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const FieldLabel('Weight (kg)'),
                            AppField(
                              controller: _weight,
                              hint: 'e.g. 0.9',
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const FieldLabel('Notes'),
                  AppField(
                    controller: _notes,
                    hint: 'Bait, weather, anything you want to remember',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  DarkButton(
                    _saving
                        ? 'Saving...'
                        : (_isEdit ? 'Save changes' : 'Confirm and save'),
                    onTap: _saving ? null : _save,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
