import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

// ---------------------------------------------------------------------------
// Species (loaded from the Supabase `species` table after sign-in)
// ---------------------------------------------------------------------------

class Species {
  const Species(this.id, this.name, this.latin, this.habitat);
  final int id;
  final String name;
  final String? latin;
  final String habitat; // freshwater, saltwater, brackish, unknown
}

// ---------------------------------------------------------------------------
// Date helpers (no extra packages)
// ---------------------------------------------------------------------------

const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

String fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';

String fmtTime(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  final ap = d.hour < 12 ? 'AM' : 'PM';
  return '$h:$m $ap';
}

String fmtDateTime(DateTime d) => '${fmtDate(d)}, ${fmtTime(d)}';

/// A new unique id, made on the phone before saving (see the plan, B.2).
String newCatchId() => const Uuid().v4();

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
    this.photoPath,
    this.localPhoto,
    this.photoSynced = true,
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

  /// Where the photo lives in Supabase Storage (null = no uploaded photo).
  String? photoPath;

  /// A photo file on this phone (picked but maybe not uploaded yet).
  String? localPhoto;

  /// false = the phone has a photo that still has to be uploaded.
  bool photoSynced;

  bool uploaded;
  bool fed; // true = this catch has a fish in the aquarium

  bool get hasPhoto => photoPath != null || localPhoto != null;
  bool get needsUpload => localPhoto != null && !photoSynced;

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
// The app's data, backed by Supabase
// ---------------------------------------------------------------------------

class AppStore extends ChangeNotifier {
  SupabaseClient get _db => Supabase.instance.client;

  static const _bucket = 'catch-photos';

  List<Species> species = [];
  List<CatchItem> catches = [];
  bool loading = false;
  String? error;

  // Who is signed in.
  String userName = '';
  String userEmail = '';

  // Privacy switches. A new account shares nothing.
  bool shareLocation = false;
  bool sharePhotos = false;
  bool allowCompare = false;

  // Signed links for private photos, kept for a while so we do not ask twice.
  final Map<String, (String, DateTime)> _urlCache = {};

  /// Loads the species list and this user's catches.
  /// Row Level Security makes sure we only get our own catches.
  Future<void> loadAll() async {
    if (loading) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final sp = await _db
          .from('species')
          .select('id, common_name, scientific_name, habitat')
          .order('common_name')
          .range(0, 999); // Supabase returns at most 1,000 rows per request
      species = [
        for (final r in sp)
          Species(
            r['id'] as int,
            r['common_name'] as String,
            r['scientific_name'] as String?,
            r['habitat'] as String,
          ),
      ];
      species.sort((a, b) {
        if (a.name == 'Unidentified / Other') return -1;
        if (b.name == 'Unidentified / Other') return 1;
        return a.name.compareTo(b.name);
      });
      debugPrint('species loaded: ${species.length}');

      final rows = await _db
          .from('catches')
          .select('*, species(common_name)')
          .order('caught_at', ascending: false);
      catches = [for (final r in rows) _fromRow(r)];
    } catch (e) {
      debugPrint('loadAll error: $e');
      error = 'Could not load your data. Check your internet.';
    }
    loading = false;
    notifyListeners();
  }

  /// Saves a new catch. The database then creates its fish by itself.
  /// The catch is saved first; the photo is uploaded after. If the photo
  /// upload fails, the catch is still saved (c.needsUpload stays true).
  Future<void> addCatch(CatchItem c) async {
    final sid = _speciesId(c.species);
    if (sid == null) throw Exception('Unknown species');
    await _db.from('catches').insert({'id': c.id, ..._toRow(c, sid)});
    c.uploaded = true;
    c.fed = true;
    catches.insert(0, c);
    notifyListeners();
    if (c.needsUpload) {
      await _uploadPhoto(c);
      notifyListeners();
    }
  }

  /// Saves changes to an existing catch (no duplicate is made).
  Future<void> updateCatch(CatchItem c) async {
    final sid = _speciesId(c.species);
    if (sid == null) throw Exception('Unknown species');
    await _db.from('catches').update(_toRow(c, sid)).eq('id', c.id);
    notifyListeners();
    if (c.needsUpload) {
      await _uploadPhoto(c);
      notifyListeners();
    }
  }

  /// Try again to upload a photo that is still waiting. Returns true if done.
  Future<bool> retryPhoto(CatchItem c) async {
    final ok = await _uploadPhoto(c);
    notifyListeners();
    return ok;
  }

  /// Uploads the local photo to `catch-photos/<user id>/<catch id>.jpg` and
  /// writes that path into the catch row. Never throws; returns success.
  Future<bool> _uploadPhoto(CatchItem c) async {
    final local = c.localPhoto;
    final uid = _db.auth.currentUser?.id;
    if (local == null || uid == null) return false;
    try {
      final path = '$uid/${c.id}.jpg';
      await _db.storage
          .from(_bucket)
          .upload(
            path,
            File(local),
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true, // replacing a photo overwrites the same path
            ),
          );
      await _db.from('catches').update({'photo_path': path}).eq('id', c.id);
      c.photoPath = path;
      c.photoSynced = true;
      _urlCache.remove(path);
      return true;
    } catch (e) {
      debugPrint('photo upload error: $e');
      return false;
    }
  }

  /// A temporary link to a private photo (valid 1 hour, we reuse it for 50 min).
  Future<String?> photoUrl(String path) async {
    final hit = _urlCache[path];
    if (hit != null && hit.$2.isAfter(DateTime.now())) return hit.$1;
    try {
      final url = await _db.storage.from(_bucket).createSignedUrl(path, 3600);
      _urlCache[path] = (url, DateTime.now().add(const Duration(minutes: 50)));
      return url;
    } catch (e) {
      debugPrint('signed url error: $e');
      return null;
    }
  }

  /// Forget everything (used on sign out so nobody sees the last user's data).
  void clear() {
    catches = [];
    userName = '';
    userEmail = '';
    _urlCache.clear();
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

  // --- helpers: convert between the app's CatchItem and a database row -----

  int? _speciesId(String name) {
    for (final s in species) {
      if (s.name == name) return s.id;
    }
    return null;
  }

  Map<String, dynamic> _toRow(CatchItem c, int speciesId) => {
    'species_id': speciesId,
    'caught_at': c.caughtAt.toUtc().toIso8601String(),
    'location_text': c.place.isEmpty ? null : c.place,
    'length_cm': double.tryParse(c.length),
    'weight_kg': double.tryParse(c.weight),
    'notes': c.notes.isEmpty ? null : c.notes,
  };

  CatchItem _fromRow(Map<String, dynamic> r) {
    final sp = r['species'] as Map<String, dynamic>?;
    return CatchItem(
      id: r['id'] as String,
      species: (sp?['common_name'] as String?) ?? 'Unknown',
      caughtAt: DateTime.parse(r['caught_at'] as String).toLocal(),
      place: (r['location_text'] as String?) ?? '',
      length: _numText(r['length_cm']),
      weight: _numText(r['weight_kg']),
      notes: (r['notes'] as String?) ?? '',
      photoPath: r['photo_path'] as String?,
      uploaded: true,
      fed: true,
    );
  }

  String _numText(Object? v) {
    if (v == null) return '';
    final n = v as num;
    return n == n.roundToDouble() ? n.toInt().toString() : n.toString();
  }
}

final AppStore store = AppStore();

// Which bottom tab is showing on the main screen: 0 = Catches, 1 = Aquarium.
final ValueNotifier<int> homeTab = ValueNotifier<int>(0);
