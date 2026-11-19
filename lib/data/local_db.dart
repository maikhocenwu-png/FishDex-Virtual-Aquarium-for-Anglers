import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// This file describes the database that lives ON THE PHONE (SQLite, through
// Drift). `local_db.g.dart` is made by running:
//   dart run build_runner build --delete-conflicting-outputs
part 'local_db.g.dart';

/// The species list, kept so the picker works with no internet.
@DataClassName('SpeciesRow')
class LocalSpecies extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text()();
  TextColumn get latin => text().nullable()();
  TextColumn get habitat => text()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Every catch of every account that signed in on this phone.
/// userId keeps one account from seeing another account's catches.
@DataClassName('CatchRow')
class LocalCatches extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get species => text()();
  DateTimeColumn get caughtAt => dateTime()();
  TextColumn get place => text()();
  TextColumn get length => text()();
  TextColumn get weight => text()();
  TextColumn get notes => text()();
  TextColumn get photoPath => text().nullable()(); // path in Supabase Storage
  TextColumn get localPhoto => text().nullable()(); // file on this phone
  BoolColumn get photoSynced => boolean()();
  BoolColumn get uploaded => boolean()(); // the catch row is in Supabase
  BoolColumn get fed => boolean()();
  BoolColumn get dirty => boolean()(); // edited, not saved online yet

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalSpecies, LocalCatches])
class LocalDb extends _$LocalDb {
  LocalDb() : super(driftDatabase(name: 'fishdex'));

  @override
  int get schemaVersion => 1;
}
