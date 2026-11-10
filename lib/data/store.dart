import 'package:flutter/foundation.dart';

// ---------------------------------------------------------------------------
// Species list (the 25-row starter list, same as supabase/species_seed.sql)
// ---------------------------------------------------------------------------

class Species {
  const Species(this.name, this.latin, this.habitat);
  final String name;
  final String? latin;
  final String habitat; // freshwater, saltwater, brackish, unknown
}

const kSpecies = <Species>[
  Species('Unidentified / Other', null, 'unknown'),
  Species('Largemouth bass', 'Micropterus salmoides', 'freshwater'),
  Species('Smallmouth bass', 'Micropterus dolomieu', 'freshwater'),
  Species('Bluegill', 'Lepomis macrochirus', 'freshwater'),
  Species('Pumpkinseed', 'Lepomis gibbosus', 'freshwater'),
  Species('Black crappie', 'Pomoxis nigromaculatus', 'freshwater'),
  Species('Yellow perch', 'Perca flavescens', 'freshwater'),
  Species('Walleye', 'Sander vitreus', 'freshwater'),
  Species('Northern pike', 'Esox lucius', 'freshwater'),
  Species('Chain pickerel', 'Esox niger', 'freshwater'),
  Species('Channel catfish', 'Ictalurus punctatus', 'freshwater'),
  Species('Common carp', 'Cyprinus carpio', 'freshwater'),
  Species('Rainbow trout', 'Oncorhynchus mykiss', 'freshwater'),
  Species('Brown trout', 'Salmo trutta', 'freshwater'),
  Species('Brook trout', 'Salvelinus fontinalis', 'freshwater'),
  Species('White perch', 'Morone americana', 'brackish'),
  Species('Striped bass', 'Morone saxatilis', 'saltwater'),
  Species('Bluefish', 'Pomatomus saltatrix', 'saltwater'),
  Species('Summer flounder (fluke)', 'Paralichthys dentatus', 'saltwater'),
  Species('Winter flounder', 'Pseudopleuronectes americanus', 'saltwater'),
  Species('Black sea bass', 'Centropristis striata', 'saltwater'),
  Species('Scup (porgy)', 'Stenotomus chrysops', 'saltwater'),
  Species('Tautog', 'Tautoga onitis', 'saltwater'),
  Species('Weakfish', 'Cynoscion regalis', 'saltwater'),
  Species('Atlantic mackerel', 'Scomber scombrus', 'saltwater'),
];

// ---------------------------------------------------------------------------
// Date helpers (no extra packages)
// ---------------------------------------------------------------------------

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ap';
}

String fmtDateTime(DateTime d) => '${fmtDate(d)}, ${fmtTime(d)}';

// ---------------------------------------------------------------------------
// A catch (one real fish the angler caught)
// ---------------------------------------------------------------------------

class CatchItem {
  CatchItem({
    required this.id,
    required this.species,
    required this.caughtAt,
    this.place = '',
    this.length = '',
    this.weight = '',
    this.notes = '',
    this.hasPhoto = false,
    this.uploaded = false,
    this.fed = false,
  });

  final String id;
  String species;
  DateTime caughtAt;
  String place;
  String length;
  String weight;
  String notes;
  bool hasPhoto;
  bool uploaded;
  bool fed;

  String get subtitle =>
      place.isEmpty ? fmtDate(caughtAt) : '${fmtDate(caughtAt)} - $place';

  String get sizeText {
    final parts = <String>[];
    if (length.isNotEmpty) parts.add('$length cm');
    if (weight.isNotEmpty) parts.add('$weight kg');
    return parts.isEmpty ? 'Not given' : parts.join(', ');
  }
}

// ---------------------------------------------------------------------------
// In-memory store for the demo (nothing is saved after the app closes)
// ---------------------------------------------------------------------------

class AppStore extends ChangeNotifier {
  final List<CatchItem> catches = [
    CatchItem(
      id: '1',
      species: 'Largemouth bass',
      caughtAt: DateTime(2026, 10, 30, 6, 40),
      place: 'Cunningham Park',
      length: '38',
      weight: '0.9',
      notes: 'Near the dock',
      hasPhoto: true,
      uploaded: false,
      fed: true,
    ),
    CatchItem(
      id: '2',
      species: 'Bluegill',
      caughtAt: DateTime(2026, 10, 12, 7, 15),
      place: 'Flushing Meadows',
      length: '19',
      weight: '0.2',
      hasPhoto: true,
      uploaded: true,
      fed: true,
    ),
    CatchItem(
      id: '3',
      species: 'Striped bass',
      caughtAt: DateTime(2026, 9, 28, 18, 5),
      place: 'Jamaica Bay',
      length: '71',
      weight: '4.2',
      hasPhoto: true,
      uploaded: true,
      fed: true,
    ),
    CatchItem(
      id: '4',
      species: 'Yellow perch',
      caughtAt: DateTime(2026, 9, 15, 8, 30),
      place: 'Alley Pond Park',
      length: '24',
      weight: '0.3',
      hasPhoto: false,
      uploaded: true,
      fed: false,
    ),
  ];

  // Privacy switches. A new account shares nothing.
  bool shareLocation = false;
  bool sharePhotos = false;
  bool allowCompare = false;

  void add(CatchItem c) {
    catches.insert(0, c);
    notifyListeners();
  }

  void changed() => notifyListeners();

  void setShareLocation(bool v) {
    shareLocation = v;
    notifyListeners();
  }

  void setSharePhotos(bool v) {
    sharePhotos = v;
    notifyListeners();
  }

  void setAllowCompare(bool v) {
    allowCompare = v;
    notifyListeners();
  }
}

final AppStore store = AppStore();

// Which bottom tab is showing on the main screen: 0 = Catches, 1 = Aquarium.
final ValueNotifier<int> homeTab = ValueNotifier<int>(0);
