// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $LocalSpeciesTable extends LocalSpecies
    with TableInfo<$LocalSpeciesTable, SpeciesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSpeciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latinMeta = const VerificationMeta('latin');
  @override
  late final GeneratedColumn<String> latin = GeneratedColumn<String>(
    'latin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _habitatMeta = const VerificationMeta(
    'habitat',
  );
  @override
  late final GeneratedColumn<String> habitat = GeneratedColumn<String>(
    'habitat',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, latin, habitat];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_species';
  @override
  VerificationContext validateIntegrity(
    Insertable<SpeciesRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('latin')) {
      context.handle(
        _latinMeta,
        latin.isAcceptableOrUnknown(data['latin']!, _latinMeta),
      );
    }
    if (data.containsKey('habitat')) {
      context.handle(
        _habitatMeta,
        habitat.isAcceptableOrUnknown(data['habitat']!, _habitatMeta),
      );
    } else if (isInserting) {
      context.missing(_habitatMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SpeciesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SpeciesRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      latin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}latin'],
      ),
      habitat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}habitat'],
      )!,
    );
  }

  @override
  $LocalSpeciesTable createAlias(String alias) {
    return $LocalSpeciesTable(attachedDatabase, alias);
  }
}

class SpeciesRow extends DataClass implements Insertable<SpeciesRow> {
  final int id;
  final String name;
  final String? latin;
  final String habitat;
  const SpeciesRow({
    required this.id,
    required this.name,
    this.latin,
    required this.habitat,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || latin != null) {
      map['latin'] = Variable<String>(latin);
    }
    map['habitat'] = Variable<String>(habitat);
    return map;
  }

  LocalSpeciesCompanion toCompanion(bool nullToAbsent) {
    return LocalSpeciesCompanion(
      id: Value(id),
      name: Value(name),
      latin: latin == null && nullToAbsent
          ? const Value.absent()
          : Value(latin),
      habitat: Value(habitat),
    );
  }

  factory SpeciesRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SpeciesRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      latin: serializer.fromJson<String?>(json['latin']),
      habitat: serializer.fromJson<String>(json['habitat']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'latin': serializer.toJson<String?>(latin),
      'habitat': serializer.toJson<String>(habitat),
    };
  }

  SpeciesRow copyWith({
    int? id,
    String? name,
    Value<String?> latin = const Value.absent(),
    String? habitat,
  }) => SpeciesRow(
    id: id ?? this.id,
    name: name ?? this.name,
    latin: latin.present ? latin.value : this.latin,
    habitat: habitat ?? this.habitat,
  );
  SpeciesRow copyWithCompanion(LocalSpeciesCompanion data) {
    return SpeciesRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      latin: data.latin.present ? data.latin.value : this.latin,
      habitat: data.habitat.present ? data.habitat.value : this.habitat,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SpeciesRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latin: $latin, ')
          ..write('habitat: $habitat')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, latin, habitat);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SpeciesRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.latin == this.latin &&
          other.habitat == this.habitat);
}

class LocalSpeciesCompanion extends UpdateCompanion<SpeciesRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> latin;
  final Value<String> habitat;
  const LocalSpeciesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.latin = const Value.absent(),
    this.habitat = const Value.absent(),
  });
  LocalSpeciesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.latin = const Value.absent(),
    required String habitat,
  }) : name = Value(name),
       habitat = Value(habitat);
  static Insertable<SpeciesRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? latin,
    Expression<String>? habitat,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (latin != null) 'latin': latin,
      if (habitat != null) 'habitat': habitat,
    });
  }

  LocalSpeciesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? latin,
    Value<String>? habitat,
  }) {
    return LocalSpeciesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      latin: latin ?? this.latin,
      habitat: habitat ?? this.habitat,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (latin.present) {
      map['latin'] = Variable<String>(latin.value);
    }
    if (habitat.present) {
      map['habitat'] = Variable<String>(habitat.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSpeciesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('latin: $latin, ')
          ..write('habitat: $habitat')
          ..write(')'))
        .toString();
  }
}

class $LocalCatchesTable extends LocalCatches
    with TableInfo<$LocalCatchesTable, CatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _speciesMeta = const VerificationMeta(
    'species',
  );
  @override
  late final GeneratedColumn<String> species = GeneratedColumn<String>(
    'species',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _caughtAtMeta = const VerificationMeta(
    'caughtAt',
  );
  @override
  late final GeneratedColumn<DateTime> caughtAt = GeneratedColumn<DateTime>(
    'caught_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lengthMeta = const VerificationMeta('length');
  @override
  late final GeneratedColumn<String> length = GeneratedColumn<String>(
    'length',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<String> weight = GeneratedColumn<String>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localPhotoMeta = const VerificationMeta(
    'localPhoto',
  );
  @override
  late final GeneratedColumn<String> localPhoto = GeneratedColumn<String>(
    'local_photo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoSyncedMeta = const VerificationMeta(
    'photoSynced',
  );
  @override
  late final GeneratedColumn<bool> photoSynced = GeneratedColumn<bool>(
    'photo_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("photo_synced" IN (0, 1))',
    ),
  );
  static const VerificationMeta _uploadedMeta = const VerificationMeta(
    'uploaded',
  );
  @override
  late final GeneratedColumn<bool> uploaded = GeneratedColumn<bool>(
    'uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("uploaded" IN (0, 1))',
    ),
  );
  static const VerificationMeta _fedMeta = const VerificationMeta('fed');
  @override
  late final GeneratedColumn<bool> fed = GeneratedColumn<bool>(
    'fed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("fed" IN (0, 1))',
    ),
  );
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
    'dirty',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dirty" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    species,
    caughtAt,
    place,
    length,
    weight,
    notes,
    photoPath,
    localPhoto,
    photoSynced,
    uploaded,
    fed,
    dirty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_catches';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatchRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('species')) {
      context.handle(
        _speciesMeta,
        species.isAcceptableOrUnknown(data['species']!, _speciesMeta),
      );
    } else if (isInserting) {
      context.missing(_speciesMeta);
    }
    if (data.containsKey('caught_at')) {
      context.handle(
        _caughtAtMeta,
        caughtAt.isAcceptableOrUnknown(data['caught_at']!, _caughtAtMeta),
      );
    } else if (isInserting) {
      context.missing(_caughtAtMeta);
    }
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('length')) {
      context.handle(
        _lengthMeta,
        length.isAcceptableOrUnknown(data['length']!, _lengthMeta),
      );
    } else if (isInserting) {
      context.missing(_lengthMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('local_photo')) {
      context.handle(
        _localPhotoMeta,
        localPhoto.isAcceptableOrUnknown(data['local_photo']!, _localPhotoMeta),
      );
    }
    if (data.containsKey('photo_synced')) {
      context.handle(
        _photoSyncedMeta,
        photoSynced.isAcceptableOrUnknown(
          data['photo_synced']!,
          _photoSyncedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_photoSyncedMeta);
    }
    if (data.containsKey('uploaded')) {
      context.handle(
        _uploadedMeta,
        uploaded.isAcceptableOrUnknown(data['uploaded']!, _uploadedMeta),
      );
    } else if (isInserting) {
      context.missing(_uploadedMeta);
    }
    if (data.containsKey('fed')) {
      context.handle(
        _fedMeta,
        fed.isAcceptableOrUnknown(data['fed']!, _fedMeta),
      );
    } else if (isInserting) {
      context.missing(_fedMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
        _dirtyMeta,
        dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta),
      );
    } else if (isInserting) {
      context.missing(_dirtyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatchRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      species: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}species'],
      )!,
      caughtAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}caught_at'],
      )!,
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      )!,
      length: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}length'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weight'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      localPhoto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_photo'],
      ),
      photoSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}photo_synced'],
      )!,
      uploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}uploaded'],
      )!,
      fed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}fed'],
      )!,
      dirty: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dirty'],
      )!,
    );
  }

  @override
  $LocalCatchesTable createAlias(String alias) {
    return $LocalCatchesTable(attachedDatabase, alias);
  }
}

class CatchRow extends DataClass implements Insertable<CatchRow> {
  final String id;
  final String userId;
  final String species;
  final DateTime caughtAt;
  final String place;
  final String length;
  final String weight;
  final String notes;
  final String? photoPath;
  final String? localPhoto;
  final bool photoSynced;
  final bool uploaded;
  final bool fed;
  final bool dirty;
  const CatchRow({
    required this.id,
    required this.userId,
    required this.species,
    required this.caughtAt,
    required this.place,
    required this.length,
    required this.weight,
    required this.notes,
    this.photoPath,
    this.localPhoto,
    required this.photoSynced,
    required this.uploaded,
    required this.fed,
    required this.dirty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['species'] = Variable<String>(species);
    map['caught_at'] = Variable<DateTime>(caughtAt);
    map['place'] = Variable<String>(place);
    map['length'] = Variable<String>(length);
    map['weight'] = Variable<String>(weight);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || localPhoto != null) {
      map['local_photo'] = Variable<String>(localPhoto);
    }
    map['photo_synced'] = Variable<bool>(photoSynced);
    map['uploaded'] = Variable<bool>(uploaded);
    map['fed'] = Variable<bool>(fed);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  LocalCatchesCompanion toCompanion(bool nullToAbsent) {
    return LocalCatchesCompanion(
      id: Value(id),
      userId: Value(userId),
      species: Value(species),
      caughtAt: Value(caughtAt),
      place: Value(place),
      length: Value(length),
      weight: Value(weight),
      notes: Value(notes),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      localPhoto: localPhoto == null && nullToAbsent
          ? const Value.absent()
          : Value(localPhoto),
      photoSynced: Value(photoSynced),
      uploaded: Value(uploaded),
      fed: Value(fed),
      dirty: Value(dirty),
    );
  }

  factory CatchRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatchRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      species: serializer.fromJson<String>(json['species']),
      caughtAt: serializer.fromJson<DateTime>(json['caughtAt']),
      place: serializer.fromJson<String>(json['place']),
      length: serializer.fromJson<String>(json['length']),
      weight: serializer.fromJson<String>(json['weight']),
      notes: serializer.fromJson<String>(json['notes']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      localPhoto: serializer.fromJson<String?>(json['localPhoto']),
      photoSynced: serializer.fromJson<bool>(json['photoSynced']),
      uploaded: serializer.fromJson<bool>(json['uploaded']),
      fed: serializer.fromJson<bool>(json['fed']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'species': serializer.toJson<String>(species),
      'caughtAt': serializer.toJson<DateTime>(caughtAt),
      'place': serializer.toJson<String>(place),
      'length': serializer.toJson<String>(length),
      'weight': serializer.toJson<String>(weight),
      'notes': serializer.toJson<String>(notes),
      'photoPath': serializer.toJson<String?>(photoPath),
      'localPhoto': serializer.toJson<String?>(localPhoto),
      'photoSynced': serializer.toJson<bool>(photoSynced),
      'uploaded': serializer.toJson<bool>(uploaded),
      'fed': serializer.toJson<bool>(fed),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  CatchRow copyWith({
    String? id,
    String? userId,
    String? species,
    DateTime? caughtAt,
    String? place,
    String? length,
    String? weight,
    String? notes,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> localPhoto = const Value.absent(),
    bool? photoSynced,
    bool? uploaded,
    bool? fed,
    bool? dirty,
  }) => CatchRow(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    species: species ?? this.species,
    caughtAt: caughtAt ?? this.caughtAt,
    place: place ?? this.place,
    length: length ?? this.length,
    weight: weight ?? this.weight,
    notes: notes ?? this.notes,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    localPhoto: localPhoto.present ? localPhoto.value : this.localPhoto,
    photoSynced: photoSynced ?? this.photoSynced,
    uploaded: uploaded ?? this.uploaded,
    fed: fed ?? this.fed,
    dirty: dirty ?? this.dirty,
  );
  CatchRow copyWithCompanion(LocalCatchesCompanion data) {
    return CatchRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      species: data.species.present ? data.species.value : this.species,
      caughtAt: data.caughtAt.present ? data.caughtAt.value : this.caughtAt,
      place: data.place.present ? data.place.value : this.place,
      length: data.length.present ? data.length.value : this.length,
      weight: data.weight.present ? data.weight.value : this.weight,
      notes: data.notes.present ? data.notes.value : this.notes,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      localPhoto: data.localPhoto.present
          ? data.localPhoto.value
          : this.localPhoto,
      photoSynced: data.photoSynced.present
          ? data.photoSynced.value
          : this.photoSynced,
      uploaded: data.uploaded.present ? data.uploaded.value : this.uploaded,
      fed: data.fed.present ? data.fed.value : this.fed,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatchRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('species: $species, ')
          ..write('caughtAt: $caughtAt, ')
          ..write('place: $place, ')
          ..write('length: $length, ')
          ..write('weight: $weight, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('localPhoto: $localPhoto, ')
          ..write('photoSynced: $photoSynced, ')
          ..write('uploaded: $uploaded, ')
          ..write('fed: $fed, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    species,
    caughtAt,
    place,
    length,
    weight,
    notes,
    photoPath,
    localPhoto,
    photoSynced,
    uploaded,
    fed,
    dirty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatchRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.species == this.species &&
          other.caughtAt == this.caughtAt &&
          other.place == this.place &&
          other.length == this.length &&
          other.weight == this.weight &&
          other.notes == this.notes &&
          other.photoPath == this.photoPath &&
          other.localPhoto == this.localPhoto &&
          other.photoSynced == this.photoSynced &&
          other.uploaded == this.uploaded &&
          other.fed == this.fed &&
          other.dirty == this.dirty);
}

class LocalCatchesCompanion extends UpdateCompanion<CatchRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> species;
  final Value<DateTime> caughtAt;
  final Value<String> place;
  final Value<String> length;
  final Value<String> weight;
  final Value<String> notes;
  final Value<String?> photoPath;
  final Value<String?> localPhoto;
  final Value<bool> photoSynced;
  final Value<bool> uploaded;
  final Value<bool> fed;
  final Value<bool> dirty;
  final Value<int> rowid;
  const LocalCatchesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.species = const Value.absent(),
    this.caughtAt = const Value.absent(),
    this.place = const Value.absent(),
    this.length = const Value.absent(),
    this.weight = const Value.absent(),
    this.notes = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.localPhoto = const Value.absent(),
    this.photoSynced = const Value.absent(),
    this.uploaded = const Value.absent(),
    this.fed = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCatchesCompanion.insert({
    required String id,
    required String userId,
    required String species,
    required DateTime caughtAt,
    required String place,
    required String length,
    required String weight,
    required String notes,
    this.photoPath = const Value.absent(),
    this.localPhoto = const Value.absent(),
    required bool photoSynced,
    required bool uploaded,
    required bool fed,
    required bool dirty,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       species = Value(species),
       caughtAt = Value(caughtAt),
       place = Value(place),
       length = Value(length),
       weight = Value(weight),
       notes = Value(notes),
       photoSynced = Value(photoSynced),
       uploaded = Value(uploaded),
       fed = Value(fed),
       dirty = Value(dirty);
  static Insertable<CatchRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? species,
    Expression<DateTime>? caughtAt,
    Expression<String>? place,
    Expression<String>? length,
    Expression<String>? weight,
    Expression<String>? notes,
    Expression<String>? photoPath,
    Expression<String>? localPhoto,
    Expression<bool>? photoSynced,
    Expression<bool>? uploaded,
    Expression<bool>? fed,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (species != null) 'species': species,
      if (caughtAt != null) 'caught_at': caughtAt,
      if (place != null) 'place': place,
      if (length != null) 'length': length,
      if (weight != null) 'weight': weight,
      if (notes != null) 'notes': notes,
      if (photoPath != null) 'photo_path': photoPath,
      if (localPhoto != null) 'local_photo': localPhoto,
      if (photoSynced != null) 'photo_synced': photoSynced,
      if (uploaded != null) 'uploaded': uploaded,
      if (fed != null) 'fed': fed,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCatchesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? species,
    Value<DateTime>? caughtAt,
    Value<String>? place,
    Value<String>? length,
    Value<String>? weight,
    Value<String>? notes,
    Value<String?>? photoPath,
    Value<String?>? localPhoto,
    Value<bool>? photoSynced,
    Value<bool>? uploaded,
    Value<bool>? fed,
    Value<bool>? dirty,
    Value<int>? rowid,
  }) {
    return LocalCatchesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      species: species ?? this.species,
      caughtAt: caughtAt ?? this.caughtAt,
      place: place ?? this.place,
      length: length ?? this.length,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
      photoPath: photoPath ?? this.photoPath,
      localPhoto: localPhoto ?? this.localPhoto,
      photoSynced: photoSynced ?? this.photoSynced,
      uploaded: uploaded ?? this.uploaded,
      fed: fed ?? this.fed,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (species.present) {
      map['species'] = Variable<String>(species.value);
    }
    if (caughtAt.present) {
      map['caught_at'] = Variable<DateTime>(caughtAt.value);
    }
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (length.present) {
      map['length'] = Variable<String>(length.value);
    }
    if (weight.present) {
      map['weight'] = Variable<String>(weight.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (localPhoto.present) {
      map['local_photo'] = Variable<String>(localPhoto.value);
    }
    if (photoSynced.present) {
      map['photo_synced'] = Variable<bool>(photoSynced.value);
    }
    if (uploaded.present) {
      map['uploaded'] = Variable<bool>(uploaded.value);
    }
    if (fed.present) {
      map['fed'] = Variable<bool>(fed.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCatchesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('species: $species, ')
          ..write('caughtAt: $caughtAt, ')
          ..write('place: $place, ')
          ..write('length: $length, ')
          ..write('weight: $weight, ')
          ..write('notes: $notes, ')
          ..write('photoPath: $photoPath, ')
          ..write('localPhoto: $localPhoto, ')
          ..write('photoSynced: $photoSynced, ')
          ..write('uploaded: $uploaded, ')
          ..write('fed: $fed, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDb extends GeneratedDatabase {
  _$LocalDb(QueryExecutor e) : super(e);
  $LocalDbManager get managers => $LocalDbManager(this);
  late final $LocalSpeciesTable localSpecies = $LocalSpeciesTable(this);
  late final $LocalCatchesTable localCatches = $LocalCatchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localSpecies,
    localCatches,
  ];
}

typedef $$LocalSpeciesTableCreateCompanionBuilder =
    LocalSpeciesCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> latin,
      required String habitat,
    });
typedef $$LocalSpeciesTableUpdateCompanionBuilder =
    LocalSpeciesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> latin,
      Value<String> habitat,
    });

class $$LocalSpeciesTableFilterComposer
    extends Composer<_$LocalDb, $LocalSpeciesTable> {
  $$LocalSpeciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get latin => $composableBuilder(
    column: $table.latin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get habitat => $composableBuilder(
    column: $table.habitat,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSpeciesTableOrderingComposer
    extends Composer<_$LocalDb, $LocalSpeciesTable> {
  $$LocalSpeciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get latin => $composableBuilder(
    column: $table.latin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get habitat => $composableBuilder(
    column: $table.habitat,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSpeciesTableAnnotationComposer
    extends Composer<_$LocalDb, $LocalSpeciesTable> {
  $$LocalSpeciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get latin =>
      $composableBuilder(column: $table.latin, builder: (column) => column);

  GeneratedColumn<String> get habitat =>
      $composableBuilder(column: $table.habitat, builder: (column) => column);
}

class $$LocalSpeciesTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $LocalSpeciesTable,
          SpeciesRow,
          $$LocalSpeciesTableFilterComposer,
          $$LocalSpeciesTableOrderingComposer,
          $$LocalSpeciesTableAnnotationComposer,
          $$LocalSpeciesTableCreateCompanionBuilder,
          $$LocalSpeciesTableUpdateCompanionBuilder,
          (
            SpeciesRow,
            BaseReferences<_$LocalDb, $LocalSpeciesTable, SpeciesRow>,
          ),
          SpeciesRow,
          PrefetchHooks Function()
        > {
  $$LocalSpeciesTableTableManager(_$LocalDb db, $LocalSpeciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSpeciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSpeciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSpeciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> latin = const Value.absent(),
                Value<String> habitat = const Value.absent(),
              }) => LocalSpeciesCompanion(
                id: id,
                name: name,
                latin: latin,
                habitat: habitat,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> latin = const Value.absent(),
                required String habitat,
              }) => LocalSpeciesCompanion.insert(
                id: id,
                name: name,
                latin: latin,
                habitat: habitat,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSpeciesTable, SpeciesRow>(table),
                  BaseReferences<_$LocalDb, $LocalSpeciesTable, SpeciesRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSpeciesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $LocalSpeciesTable,
      SpeciesRow,
      $$LocalSpeciesTableFilterComposer,
      $$LocalSpeciesTableOrderingComposer,
      $$LocalSpeciesTableAnnotationComposer,
      $$LocalSpeciesTableCreateCompanionBuilder,
      $$LocalSpeciesTableUpdateCompanionBuilder,
      (SpeciesRow, BaseReferences<_$LocalDb, $LocalSpeciesTable, SpeciesRow>),
      SpeciesRow,
      PrefetchHooks Function()
    >;
typedef $$LocalCatchesTableCreateCompanionBuilder =
    LocalCatchesCompanion Function({
      required String id,
      required String userId,
      required String species,
      required DateTime caughtAt,
      required String place,
      required String length,
      required String weight,
      required String notes,
      Value<String?> photoPath,
      Value<String?> localPhoto,
      required bool photoSynced,
      required bool uploaded,
      required bool fed,
      required bool dirty,
      Value<int> rowid,
    });
typedef $$LocalCatchesTableUpdateCompanionBuilder =
    LocalCatchesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> species,
      Value<DateTime> caughtAt,
      Value<String> place,
      Value<String> length,
      Value<String> weight,
      Value<String> notes,
      Value<String?> photoPath,
      Value<String?> localPhoto,
      Value<bool> photoSynced,
      Value<bool> uploaded,
      Value<bool> fed,
      Value<bool> dirty,
      Value<int> rowid,
    });

class $$LocalCatchesTableFilterComposer
    extends Composer<_$LocalDb, $LocalCatchesTable> {
  $$LocalCatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get caughtAt => $composableBuilder(
    column: $table.caughtAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPhoto => $composableBuilder(
    column: $table.localPhoto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get photoSynced => $composableBuilder(
    column: $table.photoSynced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get fed => $composableBuilder(
    column: $table.fed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCatchesTableOrderingComposer
    extends Composer<_$LocalDb, $LocalCatchesTable> {
  $$LocalCatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get species => $composableBuilder(
    column: $table.species,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get caughtAt => $composableBuilder(
    column: $table.caughtAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get length => $composableBuilder(
    column: $table.length,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPhoto => $composableBuilder(
    column: $table.localPhoto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get photoSynced => $composableBuilder(
    column: $table.photoSynced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get uploaded => $composableBuilder(
    column: $table.uploaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get fed => $composableBuilder(
    column: $table.fed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dirty => $composableBuilder(
    column: $table.dirty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCatchesTableAnnotationComposer
    extends Composer<_$LocalDb, $LocalCatchesTable> {
  $$LocalCatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get species =>
      $composableBuilder(column: $table.species, builder: (column) => column);

  GeneratedColumn<DateTime> get caughtAt =>
      $composableBuilder(column: $table.caughtAt, builder: (column) => column);

  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<String> get length =>
      $composableBuilder(column: $table.length, builder: (column) => column);

  GeneratedColumn<String> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get localPhoto => $composableBuilder(
    column: $table.localPhoto,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get photoSynced => $composableBuilder(
    column: $table.photoSynced,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get uploaded =>
      $composableBuilder(column: $table.uploaded, builder: (column) => column);

  GeneratedColumn<bool> get fed =>
      $composableBuilder(column: $table.fed, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$LocalCatchesTableTableManager
    extends
        RootTableManager<
          _$LocalDb,
          $LocalCatchesTable,
          CatchRow,
          $$LocalCatchesTableFilterComposer,
          $$LocalCatchesTableOrderingComposer,
          $$LocalCatchesTableAnnotationComposer,
          $$LocalCatchesTableCreateCompanionBuilder,
          $$LocalCatchesTableUpdateCompanionBuilder,
          (CatchRow, BaseReferences<_$LocalDb, $LocalCatchesTable, CatchRow>),
          CatchRow,
          PrefetchHooks Function()
        > {
  $$LocalCatchesTableTableManager(_$LocalDb db, $LocalCatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> species = const Value.absent(),
                Value<DateTime> caughtAt = const Value.absent(),
                Value<String> place = const Value.absent(),
                Value<String> length = const Value.absent(),
                Value<String> weight = const Value.absent(),
                Value<String> notes = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> localPhoto = const Value.absent(),
                Value<bool> photoSynced = const Value.absent(),
                Value<bool> uploaded = const Value.absent(),
                Value<bool> fed = const Value.absent(),
                Value<bool> dirty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCatchesCompanion(
                id: id,
                userId: userId,
                species: species,
                caughtAt: caughtAt,
                place: place,
                length: length,
                weight: weight,
                notes: notes,
                photoPath: photoPath,
                localPhoto: localPhoto,
                photoSynced: photoSynced,
                uploaded: uploaded,
                fed: fed,
                dirty: dirty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String species,
                required DateTime caughtAt,
                required String place,
                required String length,
                required String weight,
                required String notes,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> localPhoto = const Value.absent(),
                required bool photoSynced,
                required bool uploaded,
                required bool fed,
                required bool dirty,
                Value<int> rowid = const Value.absent(),
              }) => LocalCatchesCompanion.insert(
                id: id,
                userId: userId,
                species: species,
                caughtAt: caughtAt,
                place: place,
                length: length,
                weight: weight,
                notes: notes,
                photoPath: photoPath,
                localPhoto: localPhoto,
                photoSynced: photoSynced,
                uploaded: uploaded,
                fed: fed,
                dirty: dirty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalCatchesTable, CatchRow>(table),
                  BaseReferences<_$LocalDb, $LocalCatchesTable, CatchRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDb,
      $LocalCatchesTable,
      CatchRow,
      $$LocalCatchesTableFilterComposer,
      $$LocalCatchesTableOrderingComposer,
      $$LocalCatchesTableAnnotationComposer,
      $$LocalCatchesTableCreateCompanionBuilder,
      $$LocalCatchesTableUpdateCompanionBuilder,
      (CatchRow, BaseReferences<_$LocalDb, $LocalCatchesTable, CatchRow>),
      CatchRow,
      PrefetchHooks Function()
    >;

class $LocalDbManager {
  final _$LocalDb _db;
  $LocalDbManager(this._db);
  $$LocalSpeciesTableTableManager get localSpecies =>
      $$LocalSpeciesTableTableManager(_db, _db.localSpecies);
  $$LocalCatchesTableTableManager get localCatches =>
      $$LocalCatchesTableTableManager(_db, _db.localCatches);
}
