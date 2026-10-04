// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HorariosLocalesTable extends HorariosLocales
    with TableInfo<$HorariosLocalesTable, HorarioLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HorariosLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servicioNombreMeta = const VerificationMeta('servicioNombre');
  @override
  late final GeneratedColumn<String> servicioNombre = GeneratedColumn<String>(
    'servicio_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sedeIdMeta = const VerificationMeta('sedeId');
  @override
  late final GeneratedColumn<String> sedeId = GeneratedColumn<String>(
    'sede_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaMeta = const VerificationMeta('dia');
  @override
  late final GeneratedColumn<String> dia = GeneratedColumn<String>(
    'dia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horaInicioMeta = const VerificationMeta('horaInicio');
  @override
  late final GeneratedColumn<String> horaInicio = GeneratedColumn<String>(
    'hora_inicio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horaFinMeta = const VerificationMeta('horaFin');
  @override
  late final GeneratedColumn<String> horaFin = GeneratedColumn<String>(
    'hora_fin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _guardadoEnMeta = const VerificationMeta('guardadoEn');
  @override
  late final GeneratedColumn<DateTime> guardadoEn = GeneratedColumn<DateTime>(
    'guardado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    servicioNombre,
    sedeId,
    dia,
    horaInicio,
    horaFin,
    guardadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'horarios_locales';
  @override
  VerificationContext validateIntegrity(
    Insertable<HorarioLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('servicio_nombre')) {
      context.handle(
        _servicioNombreMeta,
        servicioNombre.isAcceptableOrUnknown(data['servicio_nombre']!, _servicioNombreMeta),
      );
    } else if (isInserting) {
      context.missing(_servicioNombreMeta);
    }
    if (data.containsKey('sede_id')) {
      context.handle(_sedeIdMeta, sedeId.isAcceptableOrUnknown(data['sede_id']!, _sedeIdMeta));
    } else if (isInserting) {
      context.missing(_sedeIdMeta);
    }
    if (data.containsKey('dia')) {
      context.handle(_diaMeta, dia.isAcceptableOrUnknown(data['dia']!, _diaMeta));
    } else if (isInserting) {
      context.missing(_diaMeta);
    }
    if (data.containsKey('hora_inicio')) {
      context.handle(
        _horaInicioMeta,
        horaInicio.isAcceptableOrUnknown(data['hora_inicio']!, _horaInicioMeta),
      );
    } else if (isInserting) {
      context.missing(_horaInicioMeta);
    }
    if (data.containsKey('hora_fin')) {
      context.handle(_horaFinMeta, horaFin.isAcceptableOrUnknown(data['hora_fin']!, _horaFinMeta));
    } else if (isInserting) {
      context.missing(_horaFinMeta);
    }
    if (data.containsKey('guardado_en')) {
      context.handle(
        _guardadoEnMeta,
        guardadoEn.isAcceptableOrUnknown(data['guardado_en']!, _guardadoEnMeta),
      );
    } else if (isInserting) {
      context.missing(_guardadoEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HorarioLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HorarioLocal(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      servicioNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}servicio_nombre'],
      )!,
      sedeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sede_id'],
      )!,
      dia: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}dia'])!,
      horaInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora_inicio'],
      )!,
      horaFin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora_fin'],
      )!,
      guardadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}guardado_en'],
      )!,
    );
  }

  @override
  $HorariosLocalesTable createAlias(String alias) {
    return $HorariosLocalesTable(attachedDatabase, alias);
  }
}

class HorarioLocal extends DataClass implements Insertable<HorarioLocal> {
  final String id;
  final String servicioNombre;
  final String sedeId;
  final String dia;
  final String horaInicio;
  final String horaFin;
  final DateTime guardadoEn;
  const HorarioLocal({
    required this.id,
    required this.servicioNombre,
    required this.sedeId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.guardadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['servicio_nombre'] = Variable<String>(servicioNombre);
    map['sede_id'] = Variable<String>(sedeId);
    map['dia'] = Variable<String>(dia);
    map['hora_inicio'] = Variable<String>(horaInicio);
    map['hora_fin'] = Variable<String>(horaFin);
    map['guardado_en'] = Variable<DateTime>(guardadoEn);
    return map;
  }

  HorariosLocalesCompanion toCompanion(bool nullToAbsent) {
    return HorariosLocalesCompanion(
      id: Value(id),
      servicioNombre: Value(servicioNombre),
      sedeId: Value(sedeId),
      dia: Value(dia),
      horaInicio: Value(horaInicio),
      horaFin: Value(horaFin),
      guardadoEn: Value(guardadoEn),
    );
  }

  factory HorarioLocal.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HorarioLocal(
      id: serializer.fromJson<String>(json['id']),
      servicioNombre: serializer.fromJson<String>(json['servicioNombre']),
      sedeId: serializer.fromJson<String>(json['sedeId']),
      dia: serializer.fromJson<String>(json['dia']),
      horaInicio: serializer.fromJson<String>(json['horaInicio']),
      horaFin: serializer.fromJson<String>(json['horaFin']),
      guardadoEn: serializer.fromJson<DateTime>(json['guardadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'servicioNombre': serializer.toJson<String>(servicioNombre),
      'sedeId': serializer.toJson<String>(sedeId),
      'dia': serializer.toJson<String>(dia),
      'horaInicio': serializer.toJson<String>(horaInicio),
      'horaFin': serializer.toJson<String>(horaFin),
      'guardadoEn': serializer.toJson<DateTime>(guardadoEn),
    };
  }

  HorarioLocal copyWith({
    String? id,
    String? servicioNombre,
    String? sedeId,
    String? dia,
    String? horaInicio,
    String? horaFin,
    DateTime? guardadoEn,
  }) => HorarioLocal(
    id: id ?? this.id,
    servicioNombre: servicioNombre ?? this.servicioNombre,
    sedeId: sedeId ?? this.sedeId,
    dia: dia ?? this.dia,
    horaInicio: horaInicio ?? this.horaInicio,
    horaFin: horaFin ?? this.horaFin,
    guardadoEn: guardadoEn ?? this.guardadoEn,
  );
  HorarioLocal copyWithCompanion(HorariosLocalesCompanion data) {
    return HorarioLocal(
      id: data.id.present ? data.id.value : this.id,
      servicioNombre: data.servicioNombre.present ? data.servicioNombre.value : this.servicioNombre,
      sedeId: data.sedeId.present ? data.sedeId.value : this.sedeId,
      dia: data.dia.present ? data.dia.value : this.dia,
      horaInicio: data.horaInicio.present ? data.horaInicio.value : this.horaInicio,
      horaFin: data.horaFin.present ? data.horaFin.value : this.horaFin,
      guardadoEn: data.guardadoEn.present ? data.guardadoEn.value : this.guardadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HorarioLocal(')
          ..write('id: $id, ')
          ..write('servicioNombre: $servicioNombre, ')
          ..write('sedeId: $sedeId, ')
          ..write('dia: $dia, ')
          ..write('horaInicio: $horaInicio, ')
          ..write('horaFin: $horaFin, ')
          ..write('guardadoEn: $guardadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, servicioNombre, sedeId, dia, horaInicio, horaFin, guardadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HorarioLocal &&
          other.id == this.id &&
          other.servicioNombre == this.servicioNombre &&
          other.sedeId == this.sedeId &&
          other.dia == this.dia &&
          other.horaInicio == this.horaInicio &&
          other.horaFin == this.horaFin &&
          other.guardadoEn == this.guardadoEn);
}

class HorariosLocalesCompanion extends UpdateCompanion<HorarioLocal> {
  final Value<String> id;
  final Value<String> servicioNombre;
  final Value<String> sedeId;
  final Value<String> dia;
  final Value<String> horaInicio;
  final Value<String> horaFin;
  final Value<DateTime> guardadoEn;
  final Value<int> rowid;
  const HorariosLocalesCompanion({
    this.id = const Value.absent(),
    this.servicioNombre = const Value.absent(),
    this.sedeId = const Value.absent(),
    this.dia = const Value.absent(),
    this.horaInicio = const Value.absent(),
    this.horaFin = const Value.absent(),
    this.guardadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HorariosLocalesCompanion.insert({
    required String id,
    required String servicioNombre,
    required String sedeId,
    required String dia,
    required String horaInicio,
    required String horaFin,
    required DateTime guardadoEn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       servicioNombre = Value(servicioNombre),
       sedeId = Value(sedeId),
       dia = Value(dia),
       horaInicio = Value(horaInicio),
       horaFin = Value(horaFin),
       guardadoEn = Value(guardadoEn);
  static Insertable<HorarioLocal> custom({
    Expression<String>? id,
    Expression<String>? servicioNombre,
    Expression<String>? sedeId,
    Expression<String>? dia,
    Expression<String>? horaInicio,
    Expression<String>? horaFin,
    Expression<DateTime>? guardadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (servicioNombre != null) 'servicio_nombre': servicioNombre,
      if (sedeId != null) 'sede_id': sedeId,
      if (dia != null) 'dia': dia,
      if (horaInicio != null) 'hora_inicio': horaInicio,
      if (horaFin != null) 'hora_fin': horaFin,
      if (guardadoEn != null) 'guardado_en': guardadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HorariosLocalesCompanion copyWith({
    Value<String>? id,
    Value<String>? servicioNombre,
    Value<String>? sedeId,
    Value<String>? dia,
    Value<String>? horaInicio,
    Value<String>? horaFin,
    Value<DateTime>? guardadoEn,
    Value<int>? rowid,
  }) {
    return HorariosLocalesCompanion(
      id: id ?? this.id,
      servicioNombre: servicioNombre ?? this.servicioNombre,
      sedeId: sedeId ?? this.sedeId,
      dia: dia ?? this.dia,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      guardadoEn: guardadoEn ?? this.guardadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (servicioNombre.present) {
      map['servicio_nombre'] = Variable<String>(servicioNombre.value);
    }
    if (sedeId.present) {
      map['sede_id'] = Variable<String>(sedeId.value);
    }
    if (dia.present) {
      map['dia'] = Variable<String>(dia.value);
    }
    if (horaInicio.present) {
      map['hora_inicio'] = Variable<String>(horaInicio.value);
    }
    if (horaFin.present) {
      map['hora_fin'] = Variable<String>(horaFin.value);
    }
    if (guardadoEn.present) {
      map['guardado_en'] = Variable<DateTime>(guardadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HorariosLocalesCompanion(')
          ..write('id: $id, ')
          ..write('servicioNombre: $servicioNombre, ')
          ..write('sedeId: $sedeId, ')
          ..write('dia: $dia, ')
          ..write('horaInicio: $horaInicio, ')
          ..write('horaFin: $horaFin, ')
          ..write('guardadoEn: $guardadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HorariosLocalesTable horariosLocales = $HorariosLocalesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [horariosLocales];
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$HorariosLocalesTableCreateCompanionBuilder = HorariosLocalesCompanion Function({
  required String id,
  required String servicioNombre,
  required String sedeId,
  required String dia,
  required String horaInicio,
  required String horaFin,
  required DateTime guardadoEn,
  Value<int> rowid,
});
typedef $$HorariosLocalesTableUpdateCompanionBuilder = HorariosLocalesCompanion Function({
  Value<String> id,
  Value<String> servicioNombre,
  Value<String> sedeId,
  Value<String> dia,
  Value<String> horaInicio,
  Value<String> horaFin,
  Value<DateTime> guardadoEn,
  Value<int> rowid,
});

class $$HorariosLocalesTableFilterComposer extends Composer<_$AppDatabase, $HorariosLocalesTable> {
  $$HorariosLocalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get servicioNombre =>
      $composableBuilder(column: $table.servicioNombre, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sedeId =>
      $composableBuilder(column: $table.sedeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horaInicio =>
      $composableBuilder(column: $table.horaInicio, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get horaFin =>
      $composableBuilder(column: $table.horaFin, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get guardadoEn =>
      $composableBuilder(column: $table.guardadoEn, builder: (column) => ColumnFilters(column));
}

class $$HorariosLocalesTableOrderingComposer
    extends Composer<_$AppDatabase, $HorariosLocalesTable> {
  $$HorariosLocalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get servicioNombre => $composableBuilder(
    column: $table.servicioNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sedeId =>
      $composableBuilder(column: $table.sedeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horaInicio =>
      $composableBuilder(column: $table.horaInicio, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get horaFin =>
      $composableBuilder(column: $table.horaFin, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get guardadoEn =>
      $composableBuilder(column: $table.guardadoEn, builder: (column) => ColumnOrderings(column));
}

class $$HorariosLocalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HorariosLocalesTable> {
  $$HorariosLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get servicioNombre =>
      $composableBuilder(column: $table.servicioNombre, builder: (column) => column);

  GeneratedColumn<String> get sedeId =>
      $composableBuilder(column: $table.sedeId, builder: (column) => column);

  GeneratedColumn<String> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<String> get horaInicio =>
      $composableBuilder(column: $table.horaInicio, builder: (column) => column);

  GeneratedColumn<String> get horaFin =>
      $composableBuilder(column: $table.horaFin, builder: (column) => column);

  GeneratedColumn<DateTime> get guardadoEn =>
      $composableBuilder(column: $table.guardadoEn, builder: (column) => column);
}

class $$HorariosLocalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HorariosLocalesTable,
          HorarioLocal,
          $$HorariosLocalesTableFilterComposer,
          $$HorariosLocalesTableOrderingComposer,
          $$HorariosLocalesTableAnnotationComposer,
          $$HorariosLocalesTableCreateCompanionBuilder,
          $$HorariosLocalesTableUpdateCompanionBuilder,
          (HorarioLocal, BaseReferences<_$AppDatabase, $HorariosLocalesTable, HorarioLocal>),
          HorarioLocal,
          PrefetchHooks Function()
        > {
  $$HorariosLocalesTableTableManager(_$AppDatabase db, $HorariosLocalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HorariosLocalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HorariosLocalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HorariosLocalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> servicioNombre = const Value.absent(),
                Value<String> sedeId = const Value.absent(),
                Value<String> dia = const Value.absent(),
                Value<String> horaInicio = const Value.absent(),
                Value<String> horaFin = const Value.absent(),
                Value<DateTime> guardadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HorariosLocalesCompanion(
                id: id,
                servicioNombre: servicioNombre,
                sedeId: sedeId,
                dia: dia,
                horaInicio: horaInicio,
                horaFin: horaFin,
                guardadoEn: guardadoEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String servicioNombre,
                required String sedeId,
                required String dia,
                required String horaInicio,
                required String horaFin,
                required DateTime guardadoEn,
                Value<int> rowid = const Value.absent(),
              }) => HorariosLocalesCompanion.insert(
                id: id,
                servicioNombre: servicioNombre,
                sedeId: sedeId,
                dia: dia,
                horaInicio: horaInicio,
                horaFin: horaFin,
                guardadoEn: guardadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HorariosLocalesTable, HorarioLocal>(table),
                  BaseReferences<_$AppDatabase, $HorariosLocalesTable, HorarioLocal>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HorariosLocalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HorariosLocalesTable,
      HorarioLocal,
      $$HorariosLocalesTableFilterComposer,
      $$HorariosLocalesTableOrderingComposer,
      $$HorariosLocalesTableAnnotationComposer,
      $$HorariosLocalesTableCreateCompanionBuilder,
      $$HorariosLocalesTableUpdateCompanionBuilder,
      (HorarioLocal, BaseReferences<_$AppDatabase, $HorariosLocalesTable, HorarioLocal>),
      HorarioLocal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HorariosLocalesTableTableManager get horariosLocales =>
      $$HorariosLocalesTableTableManager(_db, _db.horariosLocales);
}
