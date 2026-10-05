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
  static const VerificationMeta _servicioNombreMeta = const VerificationMeta(
    'servicioNombre',
  );
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
  static const VerificationMeta _horaInicioMeta = const VerificationMeta(
    'horaInicio',
  );
  @override
  late final GeneratedColumn<String> horaInicio = GeneratedColumn<String>(
    'hora_inicio',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _horaFinMeta = const VerificationMeta(
    'horaFin',
  );
  @override
  late final GeneratedColumn<String> horaFin = GeneratedColumn<String>(
    'hora_fin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _guardadoEnMeta = const VerificationMeta(
    'guardadoEn',
  );
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
    activo,
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
        servicioNombre.isAcceptableOrUnknown(
          data['servicio_nombre']!,
          _servicioNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servicioNombreMeta);
    }
    if (data.containsKey('sede_id')) {
      context.handle(
        _sedeIdMeta,
        sedeId.isAcceptableOrUnknown(data['sede_id']!, _sedeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sedeIdMeta);
    }
    if (data.containsKey('dia')) {
      context.handle(
        _diaMeta,
        dia.isAcceptableOrUnknown(data['dia']!, _diaMeta),
      );
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
      context.handle(
        _horaFinMeta,
        horaFin.isAcceptableOrUnknown(data['hora_fin']!, _horaFinMeta),
      );
    } else if (isInserting) {
      context.missing(_horaFinMeta);
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
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
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      servicioNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}servicio_nombre'],
      )!,
      sedeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sede_id'],
      )!,
      dia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dia'],
      )!,
      horaInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora_inicio'],
      )!,
      horaFin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hora_fin'],
      )!,
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
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
  final bool activo;
  final DateTime guardadoEn;
  const HorarioLocal({
    required this.id,
    required this.servicioNombre,
    required this.sedeId,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.activo,
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
    map['activo'] = Variable<bool>(activo);
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
      activo: Value(activo),
      guardadoEn: Value(guardadoEn),
    );
  }

  factory HorarioLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HorarioLocal(
      id: serializer.fromJson<String>(json['id']),
      servicioNombre: serializer.fromJson<String>(json['servicioNombre']),
      sedeId: serializer.fromJson<String>(json['sedeId']),
      dia: serializer.fromJson<String>(json['dia']),
      horaInicio: serializer.fromJson<String>(json['horaInicio']),
      horaFin: serializer.fromJson<String>(json['horaFin']),
      activo: serializer.fromJson<bool>(json['activo']),
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
      'activo': serializer.toJson<bool>(activo),
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
    bool? activo,
    DateTime? guardadoEn,
  }) => HorarioLocal(
    id: id ?? this.id,
    servicioNombre: servicioNombre ?? this.servicioNombre,
    sedeId: sedeId ?? this.sedeId,
    dia: dia ?? this.dia,
    horaInicio: horaInicio ?? this.horaInicio,
    horaFin: horaFin ?? this.horaFin,
    activo: activo ?? this.activo,
    guardadoEn: guardadoEn ?? this.guardadoEn,
  );
  HorarioLocal copyWithCompanion(HorariosLocalesCompanion data) {
    return HorarioLocal(
      id: data.id.present ? data.id.value : this.id,
      servicioNombre: data.servicioNombre.present
          ? data.servicioNombre.value
          : this.servicioNombre,
      sedeId: data.sedeId.present ? data.sedeId.value : this.sedeId,
      dia: data.dia.present ? data.dia.value : this.dia,
      horaInicio: data.horaInicio.present
          ? data.horaInicio.value
          : this.horaInicio,
      horaFin: data.horaFin.present ? data.horaFin.value : this.horaFin,
      activo: data.activo.present ? data.activo.value : this.activo,
      guardadoEn: data.guardadoEn.present
          ? data.guardadoEn.value
          : this.guardadoEn,
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
          ..write('activo: $activo, ')
          ..write('guardadoEn: $guardadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    servicioNombre,
    sedeId,
    dia,
    horaInicio,
    horaFin,
    activo,
    guardadoEn,
  );
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
          other.activo == this.activo &&
          other.guardadoEn == this.guardadoEn);
}

class HorariosLocalesCompanion extends UpdateCompanion<HorarioLocal> {
  final Value<String> id;
  final Value<String> servicioNombre;
  final Value<String> sedeId;
  final Value<String> dia;
  final Value<String> horaInicio;
  final Value<String> horaFin;
  final Value<bool> activo;
  final Value<DateTime> guardadoEn;
  final Value<int> rowid;
  const HorariosLocalesCompanion({
    this.id = const Value.absent(),
    this.servicioNombre = const Value.absent(),
    this.sedeId = const Value.absent(),
    this.dia = const Value.absent(),
    this.horaInicio = const Value.absent(),
    this.horaFin = const Value.absent(),
    this.activo = const Value.absent(),
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
    this.activo = const Value.absent(),
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
    Expression<bool>? activo,
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
      if (activo != null) 'activo': activo,
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
    Value<bool>? activo,
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
      activo: activo ?? this.activo,
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
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
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
          ..write('activo: $activo, ')
          ..write('guardadoEn: $guardadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MarcasSincronizacionTable extends MarcasSincronizacion
    with TableInfo<$MarcasSincronizacionTable, MarcaSincronizacion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarcasSincronizacionTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _recursoMeta = const VerificationMeta(
    'recurso',
  );
  @override
  late final GeneratedColumn<String> recurso = GeneratedColumn<String>(
    'recurso',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [recurso, etag];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'marcas_sincronizacion';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarcaSincronizacion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('recurso')) {
      context.handle(
        _recursoMeta,
        recurso.isAcceptableOrUnknown(data['recurso']!, _recursoMeta),
      );
    } else if (isInserting) {
      context.missing(_recursoMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    } else if (isInserting) {
      context.missing(_etagMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {recurso};
  @override
  MarcaSincronizacion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarcaSincronizacion(
      recurso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recurso'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      )!,
    );
  }

  @override
  $MarcasSincronizacionTable createAlias(String alias) {
    return $MarcasSincronizacionTable(attachedDatabase, alias);
  }
}

class MarcaSincronizacion extends DataClass
    implements Insertable<MarcaSincronizacion> {
  final String recurso;
  final String etag;
  const MarcaSincronizacion({required this.recurso, required this.etag});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['recurso'] = Variable<String>(recurso);
    map['etag'] = Variable<String>(etag);
    return map;
  }

  MarcasSincronizacionCompanion toCompanion(bool nullToAbsent) {
    return MarcasSincronizacionCompanion(
      recurso: Value(recurso),
      etag: Value(etag),
    );
  }

  factory MarcaSincronizacion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarcaSincronizacion(
      recurso: serializer.fromJson<String>(json['recurso']),
      etag: serializer.fromJson<String>(json['etag']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'recurso': serializer.toJson<String>(recurso),
      'etag': serializer.toJson<String>(etag),
    };
  }

  MarcaSincronizacion copyWith({String? recurso, String? etag}) =>
      MarcaSincronizacion(
        recurso: recurso ?? this.recurso,
        etag: etag ?? this.etag,
      );
  MarcaSincronizacion copyWithCompanion(MarcasSincronizacionCompanion data) {
    return MarcaSincronizacion(
      recurso: data.recurso.present ? data.recurso.value : this.recurso,
      etag: data.etag.present ? data.etag.value : this.etag,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarcaSincronizacion(')
          ..write('recurso: $recurso, ')
          ..write('etag: $etag')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(recurso, etag);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarcaSincronizacion &&
          other.recurso == this.recurso &&
          other.etag == this.etag);
}

class MarcasSincronizacionCompanion
    extends UpdateCompanion<MarcaSincronizacion> {
  final Value<String> recurso;
  final Value<String> etag;
  final Value<int> rowid;
  const MarcasSincronizacionCompanion({
    this.recurso = const Value.absent(),
    this.etag = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MarcasSincronizacionCompanion.insert({
    required String recurso,
    required String etag,
    this.rowid = const Value.absent(),
  }) : recurso = Value(recurso),
       etag = Value(etag);
  static Insertable<MarcaSincronizacion> custom({
    Expression<String>? recurso,
    Expression<String>? etag,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (recurso != null) 'recurso': recurso,
      if (etag != null) 'etag': etag,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MarcasSincronizacionCompanion copyWith({
    Value<String>? recurso,
    Value<String>? etag,
    Value<int>? rowid,
  }) {
    return MarcasSincronizacionCompanion(
      recurso: recurso ?? this.recurso,
      etag: etag ?? this.etag,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (recurso.present) {
      map['recurso'] = Variable<String>(recurso.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarcasSincronizacionCompanion(')
          ..write('recurso: $recurso, ')
          ..write('etag: $etag, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClientesEnCajaTable extends ClientesEnCaja
    with TableInfo<$ClientesEnCajaTable, ClienteEnCajaLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientesEnCajaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _comercioIdMeta = const VerificationMeta(
    'comercioId',
  );
  @override
  late final GeneratedColumn<String> comercioId = GeneratedColumn<String>(
    'comercio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clienteIdMeta = const VerificationMeta(
    'clienteId',
  );
  @override
  late final GeneratedColumn<String> clienteId = GeneratedColumn<String>(
    'cliente_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreBusquedaMeta = const VerificationMeta(
    'nombreBusqueda',
  );
  @override
  late final GeneratedColumn<String> nombreBusqueda = GeneratedColumn<String>(
    'nombre_busqueda',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentoMeta = const VerificationMeta(
    'documento',
  );
  @override
  late final GeneratedColumn<String> documento = GeneratedColumn<String>(
    'documento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentoFinalMeta = const VerificationMeta(
    'documentoFinal',
  );
  @override
  late final GeneratedColumn<String> documentoFinal = GeneratedColumn<String>(
    'documento_final',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _celularMeta = const VerificationMeta(
    'celular',
  );
  @override
  late final GeneratedColumn<String> celular = GeneratedColumn<String>(
    'celular',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _celularFinalMeta = const VerificationMeta(
    'celularFinal',
  );
  @override
  late final GeneratedColumn<String> celularFinal = GeneratedColumn<String>(
    'celular_final',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cuentaMeta = const VerificationMeta('cuenta');
  @override
  late final GeneratedColumn<String> cuenta = GeneratedColumn<String>(
    'cuenta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    comercioId,
    clienteId,
    nombre,
    nombreBusqueda,
    documento,
    documentoFinal,
    celular,
    celularFinal,
    cuenta,
    estado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clientes_en_caja';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClienteEnCajaLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('comercio_id')) {
      context.handle(
        _comercioIdMeta,
        comercioId.isAcceptableOrUnknown(data['comercio_id']!, _comercioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_comercioIdMeta);
    }
    if (data.containsKey('cliente_id')) {
      context.handle(
        _clienteIdMeta,
        clienteId.isAcceptableOrUnknown(data['cliente_id']!, _clienteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clienteIdMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('nombre_busqueda')) {
      context.handle(
        _nombreBusquedaMeta,
        nombreBusqueda.isAcceptableOrUnknown(
          data['nombre_busqueda']!,
          _nombreBusquedaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreBusquedaMeta);
    }
    if (data.containsKey('documento')) {
      context.handle(
        _documentoMeta,
        documento.isAcceptableOrUnknown(data['documento']!, _documentoMeta),
      );
    } else if (isInserting) {
      context.missing(_documentoMeta);
    }
    if (data.containsKey('documento_final')) {
      context.handle(
        _documentoFinalMeta,
        documentoFinal.isAcceptableOrUnknown(
          data['documento_final']!,
          _documentoFinalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_documentoFinalMeta);
    }
    if (data.containsKey('celular')) {
      context.handle(
        _celularMeta,
        celular.isAcceptableOrUnknown(data['celular']!, _celularMeta),
      );
    }
    if (data.containsKey('celular_final')) {
      context.handle(
        _celularFinalMeta,
        celularFinal.isAcceptableOrUnknown(
          data['celular_final']!,
          _celularFinalMeta,
        ),
      );
    }
    if (data.containsKey('cuenta')) {
      context.handle(
        _cuentaMeta,
        cuenta.isAcceptableOrUnknown(data['cuenta']!, _cuentaMeta),
      );
    } else if (isInserting) {
      context.missing(_cuentaMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {comercioId, clienteId};
  @override
  ClienteEnCajaLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClienteEnCajaLocal(
      comercioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comercio_id'],
      )!,
      clienteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cliente_id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      nombreBusqueda: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_busqueda'],
      )!,
      documento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documento'],
      )!,
      documentoFinal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}documento_final'],
      )!,
      celular: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}celular'],
      ),
      celularFinal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}celular_final'],
      ),
      cuenta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cuenta'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
    );
  }

  @override
  $ClientesEnCajaTable createAlias(String alias) {
    return $ClientesEnCajaTable(attachedDatabase, alias);
  }
}

class ClienteEnCajaLocal extends DataClass
    implements Insertable<ClienteEnCajaLocal> {
  final String comercioId;
  final String clienteId;
  final String nombre;

  /// Minúsculas y sin tildes, como lo manda la API.
  final String nombreBusqueda;

  /// "****5678".
  final String documento;
  final String documentoFinal;

  /// "••• 8888".
  final String? celular;
  final String? celularFinal;

  /// ACTIVA, PENDIENTE o SIN_CUENTA.
  final String cuenta;

  /// ACTIVE, BLOCKED o ENDED.
  final String estado;
  const ClienteEnCajaLocal({
    required this.comercioId,
    required this.clienteId,
    required this.nombre,
    required this.nombreBusqueda,
    required this.documento,
    required this.documentoFinal,
    this.celular,
    this.celularFinal,
    required this.cuenta,
    required this.estado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['comercio_id'] = Variable<String>(comercioId);
    map['cliente_id'] = Variable<String>(clienteId);
    map['nombre'] = Variable<String>(nombre);
    map['nombre_busqueda'] = Variable<String>(nombreBusqueda);
    map['documento'] = Variable<String>(documento);
    map['documento_final'] = Variable<String>(documentoFinal);
    if (!nullToAbsent || celular != null) {
      map['celular'] = Variable<String>(celular);
    }
    if (!nullToAbsent || celularFinal != null) {
      map['celular_final'] = Variable<String>(celularFinal);
    }
    map['cuenta'] = Variable<String>(cuenta);
    map['estado'] = Variable<String>(estado);
    return map;
  }

  ClientesEnCajaCompanion toCompanion(bool nullToAbsent) {
    return ClientesEnCajaCompanion(
      comercioId: Value(comercioId),
      clienteId: Value(clienteId),
      nombre: Value(nombre),
      nombreBusqueda: Value(nombreBusqueda),
      documento: Value(documento),
      documentoFinal: Value(documentoFinal),
      celular: celular == null && nullToAbsent
          ? const Value.absent()
          : Value(celular),
      celularFinal: celularFinal == null && nullToAbsent
          ? const Value.absent()
          : Value(celularFinal),
      cuenta: Value(cuenta),
      estado: Value(estado),
    );
  }

  factory ClienteEnCajaLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClienteEnCajaLocal(
      comercioId: serializer.fromJson<String>(json['comercioId']),
      clienteId: serializer.fromJson<String>(json['clienteId']),
      nombre: serializer.fromJson<String>(json['nombre']),
      nombreBusqueda: serializer.fromJson<String>(json['nombreBusqueda']),
      documento: serializer.fromJson<String>(json['documento']),
      documentoFinal: serializer.fromJson<String>(json['documentoFinal']),
      celular: serializer.fromJson<String?>(json['celular']),
      celularFinal: serializer.fromJson<String?>(json['celularFinal']),
      cuenta: serializer.fromJson<String>(json['cuenta']),
      estado: serializer.fromJson<String>(json['estado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'comercioId': serializer.toJson<String>(comercioId),
      'clienteId': serializer.toJson<String>(clienteId),
      'nombre': serializer.toJson<String>(nombre),
      'nombreBusqueda': serializer.toJson<String>(nombreBusqueda),
      'documento': serializer.toJson<String>(documento),
      'documentoFinal': serializer.toJson<String>(documentoFinal),
      'celular': serializer.toJson<String?>(celular),
      'celularFinal': serializer.toJson<String?>(celularFinal),
      'cuenta': serializer.toJson<String>(cuenta),
      'estado': serializer.toJson<String>(estado),
    };
  }

  ClienteEnCajaLocal copyWith({
    String? comercioId,
    String? clienteId,
    String? nombre,
    String? nombreBusqueda,
    String? documento,
    String? documentoFinal,
    Value<String?> celular = const Value.absent(),
    Value<String?> celularFinal = const Value.absent(),
    String? cuenta,
    String? estado,
  }) => ClienteEnCajaLocal(
    comercioId: comercioId ?? this.comercioId,
    clienteId: clienteId ?? this.clienteId,
    nombre: nombre ?? this.nombre,
    nombreBusqueda: nombreBusqueda ?? this.nombreBusqueda,
    documento: documento ?? this.documento,
    documentoFinal: documentoFinal ?? this.documentoFinal,
    celular: celular.present ? celular.value : this.celular,
    celularFinal: celularFinal.present ? celularFinal.value : this.celularFinal,
    cuenta: cuenta ?? this.cuenta,
    estado: estado ?? this.estado,
  );
  ClienteEnCajaLocal copyWithCompanion(ClientesEnCajaCompanion data) {
    return ClienteEnCajaLocal(
      comercioId: data.comercioId.present
          ? data.comercioId.value
          : this.comercioId,
      clienteId: data.clienteId.present ? data.clienteId.value : this.clienteId,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      nombreBusqueda: data.nombreBusqueda.present
          ? data.nombreBusqueda.value
          : this.nombreBusqueda,
      documento: data.documento.present ? data.documento.value : this.documento,
      documentoFinal: data.documentoFinal.present
          ? data.documentoFinal.value
          : this.documentoFinal,
      celular: data.celular.present ? data.celular.value : this.celular,
      celularFinal: data.celularFinal.present
          ? data.celularFinal.value
          : this.celularFinal,
      cuenta: data.cuenta.present ? data.cuenta.value : this.cuenta,
      estado: data.estado.present ? data.estado.value : this.estado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClienteEnCajaLocal(')
          ..write('comercioId: $comercioId, ')
          ..write('clienteId: $clienteId, ')
          ..write('nombre: $nombre, ')
          ..write('nombreBusqueda: $nombreBusqueda, ')
          ..write('documento: $documento, ')
          ..write('documentoFinal: $documentoFinal, ')
          ..write('celular: $celular, ')
          ..write('celularFinal: $celularFinal, ')
          ..write('cuenta: $cuenta, ')
          ..write('estado: $estado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    comercioId,
    clienteId,
    nombre,
    nombreBusqueda,
    documento,
    documentoFinal,
    celular,
    celularFinal,
    cuenta,
    estado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClienteEnCajaLocal &&
          other.comercioId == this.comercioId &&
          other.clienteId == this.clienteId &&
          other.nombre == this.nombre &&
          other.nombreBusqueda == this.nombreBusqueda &&
          other.documento == this.documento &&
          other.documentoFinal == this.documentoFinal &&
          other.celular == this.celular &&
          other.celularFinal == this.celularFinal &&
          other.cuenta == this.cuenta &&
          other.estado == this.estado);
}

class ClientesEnCajaCompanion extends UpdateCompanion<ClienteEnCajaLocal> {
  final Value<String> comercioId;
  final Value<String> clienteId;
  final Value<String> nombre;
  final Value<String> nombreBusqueda;
  final Value<String> documento;
  final Value<String> documentoFinal;
  final Value<String?> celular;
  final Value<String?> celularFinal;
  final Value<String> cuenta;
  final Value<String> estado;
  final Value<int> rowid;
  const ClientesEnCajaCompanion({
    this.comercioId = const Value.absent(),
    this.clienteId = const Value.absent(),
    this.nombre = const Value.absent(),
    this.nombreBusqueda = const Value.absent(),
    this.documento = const Value.absent(),
    this.documentoFinal = const Value.absent(),
    this.celular = const Value.absent(),
    this.celularFinal = const Value.absent(),
    this.cuenta = const Value.absent(),
    this.estado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientesEnCajaCompanion.insert({
    required String comercioId,
    required String clienteId,
    required String nombre,
    required String nombreBusqueda,
    required String documento,
    required String documentoFinal,
    this.celular = const Value.absent(),
    this.celularFinal = const Value.absent(),
    required String cuenta,
    required String estado,
    this.rowid = const Value.absent(),
  }) : comercioId = Value(comercioId),
       clienteId = Value(clienteId),
       nombre = Value(nombre),
       nombreBusqueda = Value(nombreBusqueda),
       documento = Value(documento),
       documentoFinal = Value(documentoFinal),
       cuenta = Value(cuenta),
       estado = Value(estado);
  static Insertable<ClienteEnCajaLocal> custom({
    Expression<String>? comercioId,
    Expression<String>? clienteId,
    Expression<String>? nombre,
    Expression<String>? nombreBusqueda,
    Expression<String>? documento,
    Expression<String>? documentoFinal,
    Expression<String>? celular,
    Expression<String>? celularFinal,
    Expression<String>? cuenta,
    Expression<String>? estado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (comercioId != null) 'comercio_id': comercioId,
      if (clienteId != null) 'cliente_id': clienteId,
      if (nombre != null) 'nombre': nombre,
      if (nombreBusqueda != null) 'nombre_busqueda': nombreBusqueda,
      if (documento != null) 'documento': documento,
      if (documentoFinal != null) 'documento_final': documentoFinal,
      if (celular != null) 'celular': celular,
      if (celularFinal != null) 'celular_final': celularFinal,
      if (cuenta != null) 'cuenta': cuenta,
      if (estado != null) 'estado': estado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientesEnCajaCompanion copyWith({
    Value<String>? comercioId,
    Value<String>? clienteId,
    Value<String>? nombre,
    Value<String>? nombreBusqueda,
    Value<String>? documento,
    Value<String>? documentoFinal,
    Value<String?>? celular,
    Value<String?>? celularFinal,
    Value<String>? cuenta,
    Value<String>? estado,
    Value<int>? rowid,
  }) {
    return ClientesEnCajaCompanion(
      comercioId: comercioId ?? this.comercioId,
      clienteId: clienteId ?? this.clienteId,
      nombre: nombre ?? this.nombre,
      nombreBusqueda: nombreBusqueda ?? this.nombreBusqueda,
      documento: documento ?? this.documento,
      documentoFinal: documentoFinal ?? this.documentoFinal,
      celular: celular ?? this.celular,
      celularFinal: celularFinal ?? this.celularFinal,
      cuenta: cuenta ?? this.cuenta,
      estado: estado ?? this.estado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (comercioId.present) {
      map['comercio_id'] = Variable<String>(comercioId.value);
    }
    if (clienteId.present) {
      map['cliente_id'] = Variable<String>(clienteId.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (nombreBusqueda.present) {
      map['nombre_busqueda'] = Variable<String>(nombreBusqueda.value);
    }
    if (documento.present) {
      map['documento'] = Variable<String>(documento.value);
    }
    if (documentoFinal.present) {
      map['documento_final'] = Variable<String>(documentoFinal.value);
    }
    if (celular.present) {
      map['celular'] = Variable<String>(celular.value);
    }
    if (celularFinal.present) {
      map['celular_final'] = Variable<String>(celularFinal.value);
    }
    if (cuenta.present) {
      map['cuenta'] = Variable<String>(cuenta.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientesEnCajaCompanion(')
          ..write('comercioId: $comercioId, ')
          ..write('clienteId: $clienteId, ')
          ..write('nombre: $nombre, ')
          ..write('nombreBusqueda: $nombreBusqueda, ')
          ..write('documento: $documento, ')
          ..write('documentoFinal: $documentoFinal, ')
          ..write('celular: $celular, ')
          ..write('celularFinal: $celularFinal, ')
          ..write('cuenta: $cuenta, ')
          ..write('estado: $estado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CopiasDeClientesTable extends CopiasDeClientes
    with TableInfo<$CopiasDeClientesTable, CopiaDeClientesLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CopiasDeClientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _comercioIdMeta = const VerificationMeta(
    'comercioId',
  );
  @override
  late final GeneratedColumn<String> comercioId = GeneratedColumn<String>(
    'comercio_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<String> version = GeneratedColumn<String>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alDiaEnMeta = const VerificationMeta(
    'alDiaEn',
  );
  @override
  late final GeneratedColumn<DateTime> alDiaEn = GeneratedColumn<DateTime>(
    'al_dia_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [comercioId, version, etag, alDiaEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'copias_de_clientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<CopiaDeClientesLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('comercio_id')) {
      context.handle(
        _comercioIdMeta,
        comercioId.isAcceptableOrUnknown(data['comercio_id']!, _comercioIdMeta),
      );
    } else if (isInserting) {
      context.missing(_comercioIdMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    } else if (isInserting) {
      context.missing(_versionMeta);
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
      );
    }
    if (data.containsKey('al_dia_en')) {
      context.handle(
        _alDiaEnMeta,
        alDiaEn.isAcceptableOrUnknown(data['al_dia_en']!, _alDiaEnMeta),
      );
    } else if (isInserting) {
      context.missing(_alDiaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {comercioId};
  @override
  CopiaDeClientesLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CopiaDeClientesLocal(
      comercioId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comercio_id'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version'],
      )!,
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      alDiaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}al_dia_en'],
      )!,
    );
  }

  @override
  $CopiasDeClientesTable createAlias(String alias) {
    return $CopiasDeClientesTable(attachedDatabase, alias);
  }
}

class CopiaDeClientesLocal extends DataClass
    implements Insertable<CopiaDeClientesLocal> {
  final String comercioId;
  final String version;
  final String? etag;
  final DateTime alDiaEn;
  const CopiaDeClientesLocal({
    required this.comercioId,
    required this.version,
    this.etag,
    required this.alDiaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['comercio_id'] = Variable<String>(comercioId);
    map['version'] = Variable<String>(version);
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    map['al_dia_en'] = Variable<DateTime>(alDiaEn);
    return map;
  }

  CopiasDeClientesCompanion toCompanion(bool nullToAbsent) {
    return CopiasDeClientesCompanion(
      comercioId: Value(comercioId),
      version: Value(version),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      alDiaEn: Value(alDiaEn),
    );
  }

  factory CopiaDeClientesLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CopiaDeClientesLocal(
      comercioId: serializer.fromJson<String>(json['comercioId']),
      version: serializer.fromJson<String>(json['version']),
      etag: serializer.fromJson<String?>(json['etag']),
      alDiaEn: serializer.fromJson<DateTime>(json['alDiaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'comercioId': serializer.toJson<String>(comercioId),
      'version': serializer.toJson<String>(version),
      'etag': serializer.toJson<String?>(etag),
      'alDiaEn': serializer.toJson<DateTime>(alDiaEn),
    };
  }

  CopiaDeClientesLocal copyWith({
    String? comercioId,
    String? version,
    Value<String?> etag = const Value.absent(),
    DateTime? alDiaEn,
  }) => CopiaDeClientesLocal(
    comercioId: comercioId ?? this.comercioId,
    version: version ?? this.version,
    etag: etag.present ? etag.value : this.etag,
    alDiaEn: alDiaEn ?? this.alDiaEn,
  );
  CopiaDeClientesLocal copyWithCompanion(CopiasDeClientesCompanion data) {
    return CopiaDeClientesLocal(
      comercioId: data.comercioId.present
          ? data.comercioId.value
          : this.comercioId,
      version: data.version.present ? data.version.value : this.version,
      etag: data.etag.present ? data.etag.value : this.etag,
      alDiaEn: data.alDiaEn.present ? data.alDiaEn.value : this.alDiaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CopiaDeClientesLocal(')
          ..write('comercioId: $comercioId, ')
          ..write('version: $version, ')
          ..write('etag: $etag, ')
          ..write('alDiaEn: $alDiaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(comercioId, version, etag, alDiaEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CopiaDeClientesLocal &&
          other.comercioId == this.comercioId &&
          other.version == this.version &&
          other.etag == this.etag &&
          other.alDiaEn == this.alDiaEn);
}

class CopiasDeClientesCompanion extends UpdateCompanion<CopiaDeClientesLocal> {
  final Value<String> comercioId;
  final Value<String> version;
  final Value<String?> etag;
  final Value<DateTime> alDiaEn;
  final Value<int> rowid;
  const CopiasDeClientesCompanion({
    this.comercioId = const Value.absent(),
    this.version = const Value.absent(),
    this.etag = const Value.absent(),
    this.alDiaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CopiasDeClientesCompanion.insert({
    required String comercioId,
    required String version,
    this.etag = const Value.absent(),
    required DateTime alDiaEn,
    this.rowid = const Value.absent(),
  }) : comercioId = Value(comercioId),
       version = Value(version),
       alDiaEn = Value(alDiaEn);
  static Insertable<CopiaDeClientesLocal> custom({
    Expression<String>? comercioId,
    Expression<String>? version,
    Expression<String>? etag,
    Expression<DateTime>? alDiaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (comercioId != null) 'comercio_id': comercioId,
      if (version != null) 'version': version,
      if (etag != null) 'etag': etag,
      if (alDiaEn != null) 'al_dia_en': alDiaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CopiasDeClientesCompanion copyWith({
    Value<String>? comercioId,
    Value<String>? version,
    Value<String?>? etag,
    Value<DateTime>? alDiaEn,
    Value<int>? rowid,
  }) {
    return CopiasDeClientesCompanion(
      comercioId: comercioId ?? this.comercioId,
      version: version ?? this.version,
      etag: etag ?? this.etag,
      alDiaEn: alDiaEn ?? this.alDiaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (comercioId.present) {
      map['comercio_id'] = Variable<String>(comercioId.value);
    }
    if (version.present) {
      map['version'] = Variable<String>(version.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (alDiaEn.present) {
      map['al_dia_en'] = Variable<DateTime>(alDiaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CopiasDeClientesCompanion(')
          ..write('comercioId: $comercioId, ')
          ..write('version: $version, ')
          ..write('etag: $etag, ')
          ..write('alDiaEn: $alDiaEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HorariosLocalesTable horariosLocales = $HorariosLocalesTable(
    this,
  );
  late final $MarcasSincronizacionTable marcasSincronizacion =
      $MarcasSincronizacionTable(this);
  late final $ClientesEnCajaTable clientesEnCaja = $ClientesEnCajaTable(this);
  late final $CopiasDeClientesTable copiasDeClientes = $CopiasDeClientesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    horariosLocales,
    marcasSincronizacion,
    clientesEnCaja,
    copiasDeClientes,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$HorariosLocalesTableCreateCompanionBuilder =
    HorariosLocalesCompanion Function({
      required String id,
      required String servicioNombre,
      required String sedeId,
      required String dia,
      required String horaInicio,
      required String horaFin,
      Value<bool> activo,
      required DateTime guardadoEn,
      Value<int> rowid,
    });
typedef $$HorariosLocalesTableUpdateCompanionBuilder =
    HorariosLocalesCompanion Function({
      Value<String> id,
      Value<String> servicioNombre,
      Value<String> sedeId,
      Value<String> dia,
      Value<String> horaInicio,
      Value<String> horaFin,
      Value<bool> activo,
      Value<DateTime> guardadoEn,
      Value<int> rowid,
    });

class $$HorariosLocalesTableFilterComposer
    extends Composer<_$AppDatabase, $HorariosLocalesTable> {
  $$HorariosLocalesTableFilterComposer({
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

  ColumnFilters<String> get servicioNombre => $composableBuilder(
    column: $table.servicioNombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sedeId => $composableBuilder(
    column: $table.sedeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horaInicio => $composableBuilder(
    column: $table.horaInicio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get horaFin => $composableBuilder(
    column: $table.horaFin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get guardadoEn => $composableBuilder(
    column: $table.guardadoEn,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servicioNombre => $composableBuilder(
    column: $table.servicioNombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sedeId => $composableBuilder(
    column: $table.sedeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dia => $composableBuilder(
    column: $table.dia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horaInicio => $composableBuilder(
    column: $table.horaInicio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get horaFin => $composableBuilder(
    column: $table.horaFin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get guardadoEn => $composableBuilder(
    column: $table.guardadoEn,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get servicioNombre => $composableBuilder(
    column: $table.servicioNombre,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sedeId =>
      $composableBuilder(column: $table.sedeId, builder: (column) => column);

  GeneratedColumn<String> get dia =>
      $composableBuilder(column: $table.dia, builder: (column) => column);

  GeneratedColumn<String> get horaInicio => $composableBuilder(
    column: $table.horaInicio,
    builder: (column) => column,
  );

  GeneratedColumn<String> get horaFin =>
      $composableBuilder(column: $table.horaFin, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get guardadoEn => $composableBuilder(
    column: $table.guardadoEn,
    builder: (column) => column,
  );
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
          (
            HorarioLocal,
            BaseReferences<_$AppDatabase, $HorariosLocalesTable, HorarioLocal>,
          ),
          HorarioLocal,
          PrefetchHooks Function()
        > {
  $$HorariosLocalesTableTableManager(
    _$AppDatabase db,
    $HorariosLocalesTable table,
  ) : super(
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
                Value<bool> activo = const Value.absent(),
                Value<DateTime> guardadoEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HorariosLocalesCompanion(
                id: id,
                servicioNombre: servicioNombre,
                sedeId: sedeId,
                dia: dia,
                horaInicio: horaInicio,
                horaFin: horaFin,
                activo: activo,
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
                Value<bool> activo = const Value.absent(),
                required DateTime guardadoEn,
                Value<int> rowid = const Value.absent(),
              }) => HorariosLocalesCompanion.insert(
                id: id,
                servicioNombre: servicioNombre,
                sedeId: sedeId,
                dia: dia,
                horaInicio: horaInicio,
                horaFin: horaFin,
                activo: activo,
                guardadoEn: guardadoEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HorariosLocalesTable, HorarioLocal>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HorariosLocalesTable,
                    HorarioLocal
                  >(db, table, e),
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
      (
        HorarioLocal,
        BaseReferences<_$AppDatabase, $HorariosLocalesTable, HorarioLocal>,
      ),
      HorarioLocal,
      PrefetchHooks Function()
    >;
typedef $$MarcasSincronizacionTableCreateCompanionBuilder =
    MarcasSincronizacionCompanion Function({
      required String recurso,
      required String etag,
      Value<int> rowid,
    });
typedef $$MarcasSincronizacionTableUpdateCompanionBuilder =
    MarcasSincronizacionCompanion Function({
      Value<String> recurso,
      Value<String> etag,
      Value<int> rowid,
    });

class $$MarcasSincronizacionTableFilterComposer
    extends Composer<_$AppDatabase, $MarcasSincronizacionTable> {
  $$MarcasSincronizacionTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get recurso => $composableBuilder(
    column: $table.recurso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarcasSincronizacionTableOrderingComposer
    extends Composer<_$AppDatabase, $MarcasSincronizacionTable> {
  $$MarcasSincronizacionTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get recurso => $composableBuilder(
    column: $table.recurso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarcasSincronizacionTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarcasSincronizacionTable> {
  $$MarcasSincronizacionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get recurso =>
      $composableBuilder(column: $table.recurso, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);
}

class $$MarcasSincronizacionTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarcasSincronizacionTable,
          MarcaSincronizacion,
          $$MarcasSincronizacionTableFilterComposer,
          $$MarcasSincronizacionTableOrderingComposer,
          $$MarcasSincronizacionTableAnnotationComposer,
          $$MarcasSincronizacionTableCreateCompanionBuilder,
          $$MarcasSincronizacionTableUpdateCompanionBuilder,
          (
            MarcaSincronizacion,
            BaseReferences<
              _$AppDatabase,
              $MarcasSincronizacionTable,
              MarcaSincronizacion
            >,
          ),
          MarcaSincronizacion,
          PrefetchHooks Function()
        > {
  $$MarcasSincronizacionTableTableManager(
    _$AppDatabase db,
    $MarcasSincronizacionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarcasSincronizacionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarcasSincronizacionTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MarcasSincronizacionTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> recurso = const Value.absent(),
                Value<String> etag = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MarcasSincronizacionCompanion(
                recurso: recurso,
                etag: etag,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String recurso,
                required String etag,
                Value<int> rowid = const Value.absent(),
              }) => MarcasSincronizacionCompanion.insert(
                recurso: recurso,
                etag: etag,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MarcasSincronizacionTable, MarcaSincronizacion>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MarcasSincronizacionTable,
                    MarcaSincronizacion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarcasSincronizacionTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarcasSincronizacionTable,
      MarcaSincronizacion,
      $$MarcasSincronizacionTableFilterComposer,
      $$MarcasSincronizacionTableOrderingComposer,
      $$MarcasSincronizacionTableAnnotationComposer,
      $$MarcasSincronizacionTableCreateCompanionBuilder,
      $$MarcasSincronizacionTableUpdateCompanionBuilder,
      (
        MarcaSincronizacion,
        BaseReferences<
          _$AppDatabase,
          $MarcasSincronizacionTable,
          MarcaSincronizacion
        >,
      ),
      MarcaSincronizacion,
      PrefetchHooks Function()
    >;
typedef $$ClientesEnCajaTableCreateCompanionBuilder =
    ClientesEnCajaCompanion Function({
      required String comercioId,
      required String clienteId,
      required String nombre,
      required String nombreBusqueda,
      required String documento,
      required String documentoFinal,
      Value<String?> celular,
      Value<String?> celularFinal,
      required String cuenta,
      required String estado,
      Value<int> rowid,
    });
typedef $$ClientesEnCajaTableUpdateCompanionBuilder =
    ClientesEnCajaCompanion Function({
      Value<String> comercioId,
      Value<String> clienteId,
      Value<String> nombre,
      Value<String> nombreBusqueda,
      Value<String> documento,
      Value<String> documentoFinal,
      Value<String?> celular,
      Value<String?> celularFinal,
      Value<String> cuenta,
      Value<String> estado,
      Value<int> rowid,
    });

class $$ClientesEnCajaTableFilterComposer
    extends Composer<_$AppDatabase, $ClientesEnCajaTable> {
  $$ClientesEnCajaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get comercioId => $composableBuilder(
    column: $table.comercioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreBusqueda => $composableBuilder(
    column: $table.nombreBusqueda,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentoFinal => $composableBuilder(
    column: $table.documentoFinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get celular => $composableBuilder(
    column: $table.celular,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get celularFinal => $composableBuilder(
    column: $table.celularFinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cuenta => $composableBuilder(
    column: $table.cuenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClientesEnCajaTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientesEnCajaTable> {
  $$ClientesEnCajaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get comercioId => $composableBuilder(
    column: $table.comercioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clienteId => $composableBuilder(
    column: $table.clienteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreBusqueda => $composableBuilder(
    column: $table.nombreBusqueda,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documento => $composableBuilder(
    column: $table.documento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentoFinal => $composableBuilder(
    column: $table.documentoFinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get celular => $composableBuilder(
    column: $table.celular,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get celularFinal => $composableBuilder(
    column: $table.celularFinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cuenta => $composableBuilder(
    column: $table.cuenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientesEnCajaTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientesEnCajaTable> {
  $$ClientesEnCajaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get comercioId => $composableBuilder(
    column: $table.comercioId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get clienteId =>
      $composableBuilder(column: $table.clienteId, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get nombreBusqueda => $composableBuilder(
    column: $table.nombreBusqueda,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documento =>
      $composableBuilder(column: $table.documento, builder: (column) => column);

  GeneratedColumn<String> get documentoFinal => $composableBuilder(
    column: $table.documentoFinal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get celular =>
      $composableBuilder(column: $table.celular, builder: (column) => column);

  GeneratedColumn<String> get celularFinal => $composableBuilder(
    column: $table.celularFinal,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cuenta =>
      $composableBuilder(column: $table.cuenta, builder: (column) => column);

  GeneratedColumn<String> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);
}

class $$ClientesEnCajaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientesEnCajaTable,
          ClienteEnCajaLocal,
          $$ClientesEnCajaTableFilterComposer,
          $$ClientesEnCajaTableOrderingComposer,
          $$ClientesEnCajaTableAnnotationComposer,
          $$ClientesEnCajaTableCreateCompanionBuilder,
          $$ClientesEnCajaTableUpdateCompanionBuilder,
          (
            ClienteEnCajaLocal,
            BaseReferences<
              _$AppDatabase,
              $ClientesEnCajaTable,
              ClienteEnCajaLocal
            >,
          ),
          ClienteEnCajaLocal,
          PrefetchHooks Function()
        > {
  $$ClientesEnCajaTableTableManager(
    _$AppDatabase db,
    $ClientesEnCajaTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientesEnCajaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientesEnCajaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientesEnCajaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> comercioId = const Value.absent(),
                Value<String> clienteId = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String> nombreBusqueda = const Value.absent(),
                Value<String> documento = const Value.absent(),
                Value<String> documentoFinal = const Value.absent(),
                Value<String?> celular = const Value.absent(),
                Value<String?> celularFinal = const Value.absent(),
                Value<String> cuenta = const Value.absent(),
                Value<String> estado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientesEnCajaCompanion(
                comercioId: comercioId,
                clienteId: clienteId,
                nombre: nombre,
                nombreBusqueda: nombreBusqueda,
                documento: documento,
                documentoFinal: documentoFinal,
                celular: celular,
                celularFinal: celularFinal,
                cuenta: cuenta,
                estado: estado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String comercioId,
                required String clienteId,
                required String nombre,
                required String nombreBusqueda,
                required String documento,
                required String documentoFinal,
                Value<String?> celular = const Value.absent(),
                Value<String?> celularFinal = const Value.absent(),
                required String cuenta,
                required String estado,
                Value<int> rowid = const Value.absent(),
              }) => ClientesEnCajaCompanion.insert(
                comercioId: comercioId,
                clienteId: clienteId,
                nombre: nombre,
                nombreBusqueda: nombreBusqueda,
                documento: documento,
                documentoFinal: documentoFinal,
                celular: celular,
                celularFinal: celularFinal,
                cuenta: cuenta,
                estado: estado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ClientesEnCajaTable, ClienteEnCajaLocal>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ClientesEnCajaTable,
                    ClienteEnCajaLocal
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClientesEnCajaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientesEnCajaTable,
      ClienteEnCajaLocal,
      $$ClientesEnCajaTableFilterComposer,
      $$ClientesEnCajaTableOrderingComposer,
      $$ClientesEnCajaTableAnnotationComposer,
      $$ClientesEnCajaTableCreateCompanionBuilder,
      $$ClientesEnCajaTableUpdateCompanionBuilder,
      (
        ClienteEnCajaLocal,
        BaseReferences<_$AppDatabase, $ClientesEnCajaTable, ClienteEnCajaLocal>,
      ),
      ClienteEnCajaLocal,
      PrefetchHooks Function()
    >;
typedef $$CopiasDeClientesTableCreateCompanionBuilder =
    CopiasDeClientesCompanion Function({
      required String comercioId,
      required String version,
      Value<String?> etag,
      required DateTime alDiaEn,
      Value<int> rowid,
    });
typedef $$CopiasDeClientesTableUpdateCompanionBuilder =
    CopiasDeClientesCompanion Function({
      Value<String> comercioId,
      Value<String> version,
      Value<String?> etag,
      Value<DateTime> alDiaEn,
      Value<int> rowid,
    });

class $$CopiasDeClientesTableFilterComposer
    extends Composer<_$AppDatabase, $CopiasDeClientesTable> {
  $$CopiasDeClientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get comercioId => $composableBuilder(
    column: $table.comercioId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get alDiaEn => $composableBuilder(
    column: $table.alDiaEn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CopiasDeClientesTableOrderingComposer
    extends Composer<_$AppDatabase, $CopiasDeClientesTable> {
  $$CopiasDeClientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get comercioId => $composableBuilder(
    column: $table.comercioId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get alDiaEn => $composableBuilder(
    column: $table.alDiaEn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CopiasDeClientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CopiasDeClientesTable> {
  $$CopiasDeClientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get comercioId => $composableBuilder(
    column: $table.comercioId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<DateTime> get alDiaEn =>
      $composableBuilder(column: $table.alDiaEn, builder: (column) => column);
}

class $$CopiasDeClientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CopiasDeClientesTable,
          CopiaDeClientesLocal,
          $$CopiasDeClientesTableFilterComposer,
          $$CopiasDeClientesTableOrderingComposer,
          $$CopiasDeClientesTableAnnotationComposer,
          $$CopiasDeClientesTableCreateCompanionBuilder,
          $$CopiasDeClientesTableUpdateCompanionBuilder,
          (
            CopiaDeClientesLocal,
            BaseReferences<
              _$AppDatabase,
              $CopiasDeClientesTable,
              CopiaDeClientesLocal
            >,
          ),
          CopiaDeClientesLocal,
          PrefetchHooks Function()
        > {
  $$CopiasDeClientesTableTableManager(
    _$AppDatabase db,
    $CopiasDeClientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CopiasDeClientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CopiasDeClientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CopiasDeClientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> comercioId = const Value.absent(),
                Value<String> version = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<DateTime> alDiaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CopiasDeClientesCompanion(
                comercioId: comercioId,
                version: version,
                etag: etag,
                alDiaEn: alDiaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String comercioId,
                required String version,
                Value<String?> etag = const Value.absent(),
                required DateTime alDiaEn,
                Value<int> rowid = const Value.absent(),
              }) => CopiasDeClientesCompanion.insert(
                comercioId: comercioId,
                version: version,
                etag: etag,
                alDiaEn: alDiaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CopiasDeClientesTable, CopiaDeClientesLocal>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $CopiasDeClientesTable,
                    CopiaDeClientesLocal
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CopiasDeClientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CopiasDeClientesTable,
      CopiaDeClientesLocal,
      $$CopiasDeClientesTableFilterComposer,
      $$CopiasDeClientesTableOrderingComposer,
      $$CopiasDeClientesTableAnnotationComposer,
      $$CopiasDeClientesTableCreateCompanionBuilder,
      $$CopiasDeClientesTableUpdateCompanionBuilder,
      (
        CopiaDeClientesLocal,
        BaseReferences<
          _$AppDatabase,
          $CopiasDeClientesTable,
          CopiaDeClientesLocal
        >,
      ),
      CopiaDeClientesLocal,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HorariosLocalesTableTableManager get horariosLocales =>
      $$HorariosLocalesTableTableManager(_db, _db.horariosLocales);
  $$MarcasSincronizacionTableTableManager get marcasSincronizacion =>
      $$MarcasSincronizacionTableTableManager(_db, _db.marcasSincronizacion);
  $$ClientesEnCajaTableTableManager get clientesEnCaja =>
      $$ClientesEnCajaTableTableManager(_db, _db.clientesEnCaja);
  $$CopiasDeClientesTableTableManager get copiasDeClientes =>
      $$CopiasDeClientesTableTableManager(_db, _db.copiasDeClientes);
}
