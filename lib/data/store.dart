import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart' show Value;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'local_db.dart';

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
    this.dirty = false,
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

  /// true = edited on the phone, the changes are not saved online yet.
  bool dirty;

  /// true = something about this catch still has to reach Supabase.
  bool get waiting => !uploaded || dirty || needsUpload;

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

  // --- local copy on the phone ---------------------------------------------

  // The database on the phone (SQLite through Drift). Opens on first use.
  final LocalDb _local = LocalDb();

  void _sortSpecies() {
    species.sort((a, b) {
      if (a.name == 'Unidentified / Other') return -1;
      if (b.name == 'Unidentified / Other') return 1;
      return a.name.compareTo(b.name);
    });
  }

  /// Writes the species and this account's catches into the phone database.
  Future<void> _saveCache() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    try {
      await _local.transaction(() async {
        await _local.delete(_local.localSpecies).go();
        await (_local.delete(
          _local.localCatches,
        )..where((t) => t.userId.equals(uid))).go();
        await _local.batch((b) {
          b.insertAll(_local.localSpecies, [
            for (final s in species)
              LocalSpeciesCompanion.insert(
                id: Value(s.id),
                name: s.name,
                latin: Value(s.latin),
                habitat: s.habitat,
              ),
          ]);
          b.insertAll(_local.localCatches, [
            for (final c in catches)
              LocalCatchesCompanion.insert(
                id: c.id,
                userId: uid,
                species: c.species,
                caughtAt: c.caughtAt,
                place: c.place,
                length: c.length,
                weight: c.weight,
                notes: c.notes,
                photoPath: Value(c.photoPath),
                localPhoto: Value(c.localPhoto),
                photoSynced: c.photoSynced,
                uploaded: c.uploaded,
                fed: c.fed,
                dirty: c.dirty,
              ),
          ]);
        });
      });
    } catch (e) {
      debugPrint('save cache error: $e');
    }
  }

  /// Reads the phone database, so the app has data even with no internet.
  Future<void> loadCache() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    try {
      final sp = await _local.select(_local.localSpecies).get();
      final rows = await (_local.select(
        _local.localCatches,
      )..where((t) => t.userId.equals(uid))).get();
      species = [for (final r in sp) Species(r.id, r.name, r.latin, r.habitat)];
      _sortSpecies();
      catches = [
        for (final r in rows)
          CatchItem(
            id: r.id,
            species: r.species,
            caughtAt: r.caughtAt,
            place: r.place,
            length: r.length,
            weight: r.weight,
            notes: r.notes,
            photoPath: r.photoPath,
            localPhoto: r.localPhoto,
            photoSynced: r.photoSynced,
            uploaded: r.uploaded,
            fed: r.fed,
            dirty: r.dirty,
          ),
      ]..sort((a, b) => b.caughtAt.compareTo(a.caughtAt));
      notifyListeners();
    } catch (e) {
      debugPrint('load cache error: $e');
    }
  }

  String? _cacheUid; // whose saved copy is loaded in memory

  // When the phone gets internet back, sync by itself.
  bool _autoSync = false;

  void _startAutoSync() {
    if (_autoSync) return;
    _autoSync = true;
    Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && _db.auth.currentUser != null) loadAll();
    });
  }

  // --- loading and saving ---------------------------------------------------

  /// Shows the saved copy at once, sends anything waiting to Supabase, then
  /// refreshes from Supabase. With no internet you keep seeing the saved copy.
  /// Row Level Security makes sure we only get our own catches.
  Future<void> loadAll() async {
    if (loading) return;
    _startAutoSync();
    loading = true;
    error = null;
    notifyListeners();
    final uid = _db.auth.currentUser?.id;
    if (_cacheUid != uid) {
      _cacheUid = uid; // read this account's saved copy once per sign-in
      await loadCache();
    }
    try {
      await _syncPending(); // never throws

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
      _sortSpecies();
      debugPrint('species loaded: ${species.length}');

      final rows = await _db
          .from('catches')
          .select('*, species(common_name)')
          .order('caught_at', ascending: false);

      final old = {for (final c in catches) c.id: c};
      final fresh = <CatchItem>[];
      for (final r in rows) {
        final item = _fromRow(r);
        final o = old[item.id];
        if (o != null) {
          if (o.dirty) {
            fresh.add(o); // keep edits that are not online yet
            continue;
          }
          if (o.localPhoto != null) {
            item.localPhoto = o.localPhoto;
            item.photoSynced = o.photoSynced;
          }
        }
        fresh.add(item);
      }
      // catches saved on the phone that Supabase does not have yet
      final serverIds = {for (final c in fresh) c.id};
      final pending = catches.where(
        (c) => !c.uploaded && !serverIds.contains(c.id),
      );
      catches = [...pending, ...fresh]
        ..sort((a, b) => b.caughtAt.compareTo(a.caughtAt));
      await _saveCache();
    } catch (e) {
      debugPrint('loadAll error: $e');
      error = catches.isEmpty
          ? 'Could not load your data. Check your internet.'
          : 'Offline. Showing what is saved on your phone.';
    }
    loading = false;
    notifyListeners();
  }

  /// Saves a new catch ON THE PHONE first, then sends it to Supabase. With no
  /// internet it stays on the phone (c.waiting) and syncs later.
  /// The database creates the fish by itself once the catch arrives.
  Future<void> addCatch(CatchItem c) async {
    if (_speciesId(c.species) == null) throw Exception('Unknown species');
    c.uploaded = false;
    c.fed = false;
    catches.insert(0, c);
    notifyListeners();
    await _saveCache();
    try {
      await _syncOne(c);
    } on PostgrestException {
      // The database refused it (for example length 0). Do not keep it.
      catches.remove(c);
      notifyListeners();
      await _saveCache();
      rethrow;
    } catch (e) {
      debugPrint('saved on the phone only: $e'); // no internet
    }
    notifyListeners();
    await _saveCache();
  }

  /// Saves changes to an existing catch (no duplicate is made).
  Future<void> updateCatch(CatchItem c) async {
    if (_speciesId(c.species) == null) throw Exception('Unknown species');
    c.dirty = true;
    notifyListeners();
    await _saveCache();
    try {
      await _syncOne(c);
    } on PostgrestException {
      c.dirty = false; // refused; the screen reloads the real data
      rethrow;
    } catch (e) {
      debugPrint('edit kept on the phone only: $e'); // no internet
    }
    notifyListeners();
    await _saveCache();
  }

  /// Try again to send everything that is waiting. Returns true if done.
  Future<bool> retryPhoto(CatchItem c) async {
    try {
      await _syncOne(c);
    } catch (e) {
      debugPrint('retry error: $e');
    }
    notifyListeners();
    await _saveCache();
    return !c.waiting;
  }

  /// Sends one catch's waiting parts: the new row, or the edits, then the photo.
  /// Throws if there is no internet or the database refuses.
  Future<void> _syncOne(CatchItem c) async {
    final sid = _speciesId(c.species);
    if (sid == null) return;
    if (!c.uploaded) {
      await _db.from('catches').insert({'id': c.id, ..._toRow(c, sid)});
      c.uploaded = true;
      c.fed = true;
      c.dirty = false;
    } else if (c.dirty) {
      await _db.from('catches').update(_toRow(c, sid)).eq('id', c.id);
      c.dirty = false;
    }
    if (c.needsUpload) await _uploadPhoto(c);
  }

  /// Sends everything that is waiting. Stops quietly if there is no internet.
  Future<void> _syncPending() async {
    for (final c in List.of(catches)) {
      if (!c.waiting) continue;
      try {
        await _syncOne(c);
      } on PostgrestException catch (e) {
        // 23505 = this id is already there (an earlier send actually worked).
        if (e.code == '23505') {
          c.uploaded = true;
          c.fed = true;
        }
        debugPrint('sync refused: ${e.message}');
      } catch (e) {
        debugPrint('sync stopped (offline?): $e');
        break;
      }
    }
    await _saveCache();
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
    _cacheUid = null;
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
