// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OutboxEventsTable extends OutboxEvents with TableInfo<$OutboxEventsTable, OutboxEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindCodeMeta = const VerificationMeta('kindCode');
  @override
  late final GeneratedColumn<String> kindCode = GeneratedColumn<String>(
    'kind_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta('payloadJson');
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusCodeMeta = const VerificationMeta('statusCode');
  @override
  late final GeneratedColumn<String> statusCode = GeneratedColumn<String>(
    'status_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rejectionReasonCodeMeta = const VerificationMeta(
    'rejectionReasonCode',
  );
  @override
  late final GeneratedColumn<String> rejectionReasonCode = GeneratedColumn<String>(
    'rejection_reason_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchIdMeta = const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deliveredAtMeta = const VerificationMeta('deliveredAt');
  @override
  late final GeneratedColumn<DateTime> deliveredAt = GeneratedColumn<DateTime>(
    'delivered_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kindCode,
    occurredAt,
    payloadJson,
    statusCode,
    rejectionReasonCode,
    batchId,
    attempts,
    deliveredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('kind_code')) {
      context.handle(
        _kindCodeMeta,
        kindCode.isAcceptableOrUnknown(data['kind_code']!, _kindCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_kindCodeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(data['payload_json']!, _payloadJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status_code')) {
      context.handle(
        _statusCodeMeta,
        statusCode.isAcceptableOrUnknown(data['status_code']!, _statusCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_statusCodeMeta);
    }
    if (data.containsKey('rejection_reason_code')) {
      context.handle(
        _rejectionReasonCodeMeta,
        rejectionReasonCode.isAcceptableOrUnknown(
          data['rejection_reason_code']!,
          _rejectionReasonCodeMeta,
        ),
      );
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta, batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('delivered_at')) {
      context.handle(
        _deliveredAtMeta,
        deliveredAt.isAcceptableOrUnknown(data['delivered_at']!, _deliveredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEvent(
      id: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      kindCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind_code'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      statusCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status_code'],
      )!,
      rejectionReasonCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejection_reason_code'],
      ),
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      deliveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivered_at'],
      ),
    );
  }

  @override
  $OutboxEventsTable createAlias(String alias) {
    return $OutboxEventsTable(attachedDatabase, alias);
  }
}

class OutboxEvent extends DataClass implements Insertable<OutboxEvent> {
  /// UUID v7 generado en el celular; será sync.inbound_events.id en el servidor.
  final String id;

  /// Código de sync.inbound_event_kinds (CONSUMPTION, SALE...).
  final String kindCode;

  /// Hora real en que ocurrió, en UTC.
  final DateTime occurredAt;
  final String payloadJson;

  /// PENDING mientras no hay respuesta; luego el código que devolvió el
  /// servidor (APPLIED, REJECTED), igual que sync.inbound_event_statuses.
  final String statusCode;
  final String? rejectionReasonCode;

  /// Lote al que se asignó. Si el envío falla, se reenvía el mismo lote.
  final String? batchId;
  final int attempts;
  final DateTime? deliveredAt;
  const OutboxEvent({
    required this.id,
    required this.kindCode,
    required this.occurredAt,
    required this.payloadJson,
    required this.statusCode,
    this.rejectionReasonCode,
    this.batchId,
    required this.attempts,
    this.deliveredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['kind_code'] = Variable<String>(kindCode);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status_code'] = Variable<String>(statusCode);
    if (!nullToAbsent || rejectionReasonCode != null) {
      map['rejection_reason_code'] = Variable<String>(rejectionReasonCode);
    }
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || deliveredAt != null) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt);
    }
    return map;
  }

  OutboxEventsCompanion toCompanion(bool nullToAbsent) {
    return OutboxEventsCompanion(
      id: Value(id),
      kindCode: Value(kindCode),
      occurredAt: Value(occurredAt),
      payloadJson: Value(payloadJson),
      statusCode: Value(statusCode),
      rejectionReasonCode: rejectionReasonCode == null && nullToAbsent
          ? const Value.absent()
          : Value(rejectionReasonCode),
      batchId: batchId == null && nullToAbsent ? const Value.absent() : Value(batchId),
      attempts: Value(attempts),
      deliveredAt: deliveredAt == null && nullToAbsent ? const Value.absent() : Value(deliveredAt),
    );
  }

  factory OutboxEvent.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEvent(
      id: serializer.fromJson<String>(json['id']),
      kindCode: serializer.fromJson<String>(json['kindCode']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      statusCode: serializer.fromJson<String>(json['statusCode']),
      rejectionReasonCode: serializer.fromJson<String?>(json['rejectionReasonCode']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      deliveredAt: serializer.fromJson<DateTime?>(json['deliveredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'kindCode': serializer.toJson<String>(kindCode),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'statusCode': serializer.toJson<String>(statusCode),
      'rejectionReasonCode': serializer.toJson<String?>(rejectionReasonCode),
      'batchId': serializer.toJson<String?>(batchId),
      'attempts': serializer.toJson<int>(attempts),
      'deliveredAt': serializer.toJson<DateTime?>(deliveredAt),
    };
  }

  OutboxEvent copyWith({
    String? id,
    String? kindCode,
    DateTime? occurredAt,
    String? payloadJson,
    String? statusCode,
    Value<String?> rejectionReasonCode = const Value.absent(),
    Value<String?> batchId = const Value.absent(),
    int? attempts,
    Value<DateTime?> deliveredAt = const Value.absent(),
  }) => OutboxEvent(
    id: id ?? this.id,
    kindCode: kindCode ?? this.kindCode,
    occurredAt: occurredAt ?? this.occurredAt,
    payloadJson: payloadJson ?? this.payloadJson,
    statusCode: statusCode ?? this.statusCode,
    rejectionReasonCode: rejectionReasonCode.present
        ? rejectionReasonCode.value
        : this.rejectionReasonCode,
    batchId: batchId.present ? batchId.value : this.batchId,
    attempts: attempts ?? this.attempts,
    deliveredAt: deliveredAt.present ? deliveredAt.value : this.deliveredAt,
  );
  OutboxEvent copyWithCompanion(OutboxEventsCompanion data) {
    return OutboxEvent(
      id: data.id.present ? data.id.value : this.id,
      kindCode: data.kindCode.present ? data.kindCode.value : this.kindCode,
      occurredAt: data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      payloadJson: data.payloadJson.present ? data.payloadJson.value : this.payloadJson,
      statusCode: data.statusCode.present ? data.statusCode.value : this.statusCode,
      rejectionReasonCode: data.rejectionReasonCode.present
          ? data.rejectionReasonCode.value
          : this.rejectionReasonCode,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      deliveredAt: data.deliveredAt.present ? data.deliveredAt.value : this.deliveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEvent(')
          ..write('id: $id, ')
          ..write('kindCode: $kindCode, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('statusCode: $statusCode, ')
          ..write('rejectionReasonCode: $rejectionReasonCode, ')
          ..write('batchId: $batchId, ')
          ..write('attempts: $attempts, ')
          ..write('deliveredAt: $deliveredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kindCode,
    occurredAt,
    payloadJson,
    statusCode,
    rejectionReasonCode,
    batchId,
    attempts,
    deliveredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEvent &&
          other.id == this.id &&
          other.kindCode == this.kindCode &&
          other.occurredAt == this.occurredAt &&
          other.payloadJson == this.payloadJson &&
          other.statusCode == this.statusCode &&
          other.rejectionReasonCode == this.rejectionReasonCode &&
          other.batchId == this.batchId &&
          other.attempts == this.attempts &&
          other.deliveredAt == this.deliveredAt);
}

class OutboxEventsCompanion extends UpdateCompanion<OutboxEvent> {
  final Value<String> id;
  final Value<String> kindCode;
  final Value<DateTime> occurredAt;
  final Value<String> payloadJson;
  final Value<String> statusCode;
  final Value<String?> rejectionReasonCode;
  final Value<String?> batchId;
  final Value<int> attempts;
  final Value<DateTime?> deliveredAt;
  final Value<int> rowid;
  const OutboxEventsCompanion({
    this.id = const Value.absent(),
    this.kindCode = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.statusCode = const Value.absent(),
    this.rejectionReasonCode = const Value.absent(),
    this.batchId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEventsCompanion.insert({
    required String id,
    required String kindCode,
    required DateTime occurredAt,
    required String payloadJson,
    required String statusCode,
    this.rejectionReasonCode = const Value.absent(),
    this.batchId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.deliveredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       kindCode = Value(kindCode),
       occurredAt = Value(occurredAt),
       payloadJson = Value(payloadJson),
       statusCode = Value(statusCode);
  static Insertable<OutboxEvent> custom({
    Expression<String>? id,
    Expression<String>? kindCode,
    Expression<DateTime>? occurredAt,
    Expression<String>? payloadJson,
    Expression<String>? statusCode,
    Expression<String>? rejectionReasonCode,
    Expression<String>? batchId,
    Expression<int>? attempts,
    Expression<DateTime>? deliveredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kindCode != null) 'kind_code': kindCode,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (statusCode != null) 'status_code': statusCode,
      if (rejectionReasonCode != null) 'rejection_reason_code': rejectionReasonCode,
      if (batchId != null) 'batch_id': batchId,
      if (attempts != null) 'attempts': attempts,
      if (deliveredAt != null) 'delivered_at': deliveredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? kindCode,
    Value<DateTime>? occurredAt,
    Value<String>? payloadJson,
    Value<String>? statusCode,
    Value<String?>? rejectionReasonCode,
    Value<String?>? batchId,
    Value<int>? attempts,
    Value<DateTime?>? deliveredAt,
    Value<int>? rowid,
  }) {
    return OutboxEventsCompanion(
      id: id ?? this.id,
      kindCode: kindCode ?? this.kindCode,
      occurredAt: occurredAt ?? this.occurredAt,
      payloadJson: payloadJson ?? this.payloadJson,
      statusCode: statusCode ?? this.statusCode,
      rejectionReasonCode: rejectionReasonCode ?? this.rejectionReasonCode,
      batchId: batchId ?? this.batchId,
      attempts: attempts ?? this.attempts,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (kindCode.present) {
      map['kind_code'] = Variable<String>(kindCode.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (statusCode.present) {
      map['status_code'] = Variable<String>(statusCode.value);
    }
    if (rejectionReasonCode.present) {
      map['rejection_reason_code'] = Variable<String>(rejectionReasonCode.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (deliveredAt.present) {
      map['delivered_at'] = Variable<DateTime>(deliveredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEventsCompanion(')
          ..write('id: $id, ')
          ..write('kindCode: $kindCode, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('statusCode: $statusCode, ')
          ..write('rejectionReasonCode: $rejectionReasonCode, ')
          ..write('batchId: $batchId, ')
          ..write('attempts: $attempts, ')
          ..write('deliveredAt: $deliveredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SigningKeysTable extends SigningKeys with TableInfo<$SigningKeysTable, SigningKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SigningKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tenantIdMeta = const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyIdMeta = const VerificationMeta('keyId');
  @override
  late final GeneratedColumn<String> keyId = GeneratedColumn<String>(
    'key_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _algorithmMeta = const VerificationMeta('algorithm');
  @override
  late final GeneratedColumn<String> algorithm = GeneratedColumn<String>(
    'algorithm',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta('publicKey');
  @override
  late final GeneratedColumn<Uint8List> publicKey = GeneratedColumn<Uint8List>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retiredAtMeta = const VerificationMeta('retiredAt');
  @override
  late final GeneratedColumn<DateTime> retiredAt = GeneratedColumn<DateTime>(
    'retired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [tenantId, keyId, algorithm, publicKey, retiredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'signing_keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<SigningKey> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('key_id')) {
      context.handle(_keyIdMeta, keyId.isAcceptableOrUnknown(data['key_id']!, _keyIdMeta));
    } else if (isInserting) {
      context.missing(_keyIdMeta);
    }
    if (data.containsKey('algorithm')) {
      context.handle(
        _algorithmMeta,
        algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta),
      );
    } else if (isInserting) {
      context.missing(_algorithmMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('retired_at')) {
      context.handle(
        _retiredAtMeta,
        retiredAt.isAcceptableOrUnknown(data['retired_at']!, _retiredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tenantId, keyId};
  @override
  SigningKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SigningKey(
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      keyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_id'],
      )!,
      algorithm: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}algorithm'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}public_key'],
      )!,
      retiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_at'],
      ),
    );
  }

  @override
  $SigningKeysTable createAlias(String alias) {
    return $SigningKeysTable(attachedDatabase, alias);
  }
}

class SigningKey extends DataClass implements Insertable<SigningKey> {
  final String tenantId;
  final String keyId;
  final String algorithm;
  final Uint8List publicKey;
  final DateTime? retiredAt;
  const SigningKey({
    required this.tenantId,
    required this.keyId,
    required this.algorithm,
    required this.publicKey,
    this.retiredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tenant_id'] = Variable<String>(tenantId);
    map['key_id'] = Variable<String>(keyId);
    map['algorithm'] = Variable<String>(algorithm);
    map['public_key'] = Variable<Uint8List>(publicKey);
    if (!nullToAbsent || retiredAt != null) {
      map['retired_at'] = Variable<DateTime>(retiredAt);
    }
    return map;
  }

  SigningKeysCompanion toCompanion(bool nullToAbsent) {
    return SigningKeysCompanion(
      tenantId: Value(tenantId),
      keyId: Value(keyId),
      algorithm: Value(algorithm),
      publicKey: Value(publicKey),
      retiredAt: retiredAt == null && nullToAbsent ? const Value.absent() : Value(retiredAt),
    );
  }

  factory SigningKey.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SigningKey(
      tenantId: serializer.fromJson<String>(json['tenantId']),
      keyId: serializer.fromJson<String>(json['keyId']),
      algorithm: serializer.fromJson<String>(json['algorithm']),
      publicKey: serializer.fromJson<Uint8List>(json['publicKey']),
      retiredAt: serializer.fromJson<DateTime?>(json['retiredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tenantId': serializer.toJson<String>(tenantId),
      'keyId': serializer.toJson<String>(keyId),
      'algorithm': serializer.toJson<String>(algorithm),
      'publicKey': serializer.toJson<Uint8List>(publicKey),
      'retiredAt': serializer.toJson<DateTime?>(retiredAt),
    };
  }

  SigningKey copyWith({
    String? tenantId,
    String? keyId,
    String? algorithm,
    Uint8List? publicKey,
    Value<DateTime?> retiredAt = const Value.absent(),
  }) => SigningKey(
    tenantId: tenantId ?? this.tenantId,
    keyId: keyId ?? this.keyId,
    algorithm: algorithm ?? this.algorithm,
    publicKey: publicKey ?? this.publicKey,
    retiredAt: retiredAt.present ? retiredAt.value : this.retiredAt,
  );
  SigningKey copyWithCompanion(SigningKeysCompanion data) {
    return SigningKey(
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      retiredAt: data.retiredAt.present ? data.retiredAt.value : this.retiredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SigningKey(')
          ..write('tenantId: $tenantId, ')
          ..write('keyId: $keyId, ')
          ..write('algorithm: $algorithm, ')
          ..write('publicKey: $publicKey, ')
          ..write('retiredAt: $retiredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tenantId, keyId, algorithm, $driftBlobEquality.hash(publicKey), retiredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SigningKey &&
          other.tenantId == this.tenantId &&
          other.keyId == this.keyId &&
          other.algorithm == this.algorithm &&
          $driftBlobEquality.equals(other.publicKey, this.publicKey) &&
          other.retiredAt == this.retiredAt);
}

class SigningKeysCompanion extends UpdateCompanion<SigningKey> {
  final Value<String> tenantId;
  final Value<String> keyId;
  final Value<String> algorithm;
  final Value<Uint8List> publicKey;
  final Value<DateTime?> retiredAt;
  final Value<int> rowid;
  const SigningKeysCompanion({
    this.tenantId = const Value.absent(),
    this.keyId = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SigningKeysCompanion.insert({
    required String tenantId,
    required String keyId,
    required String algorithm,
    required Uint8List publicKey,
    this.retiredAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : tenantId = Value(tenantId),
       keyId = Value(keyId),
       algorithm = Value(algorithm),
       publicKey = Value(publicKey);
  static Insertable<SigningKey> custom({
    Expression<String>? tenantId,
    Expression<String>? keyId,
    Expression<String>? algorithm,
    Expression<Uint8List>? publicKey,
    Expression<DateTime>? retiredAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tenantId != null) 'tenant_id': tenantId,
      if (keyId != null) 'key_id': keyId,
      if (algorithm != null) 'algorithm': algorithm,
      if (publicKey != null) 'public_key': publicKey,
      if (retiredAt != null) 'retired_at': retiredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SigningKeysCompanion copyWith({
    Value<String>? tenantId,
    Value<String>? keyId,
    Value<String>? algorithm,
    Value<Uint8List>? publicKey,
    Value<DateTime?>? retiredAt,
    Value<int>? rowid,
  }) {
    return SigningKeysCompanion(
      tenantId: tenantId ?? this.tenantId,
      keyId: keyId ?? this.keyId,
      algorithm: algorithm ?? this.algorithm,
      publicKey: publicKey ?? this.publicKey,
      retiredAt: retiredAt ?? this.retiredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (keyId.present) {
      map['key_id'] = Variable<String>(keyId.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<String>(algorithm.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<Uint8List>(publicKey.value);
    }
    if (retiredAt.present) {
      map['retired_at'] = Variable<DateTime>(retiredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SigningKeysCompanion(')
          ..write('tenantId: $tenantId, ')
          ..write('keyId: $keyId, ')
          ..write('algorithm: $algorithm, ')
          ..write('publicKey: $publicKey, ')
          ..write('retiredAt: $retiredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RevokedQrCodesTable extends RevokedQrCodes
    with TableInfo<$RevokedQrCodesTable, RevokedQrCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RevokedQrCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _qrCodeIdMeta = const VerificationMeta('qrCodeId');
  @override
  late final GeneratedColumn<String> qrCodeId = GeneratedColumn<String>(
    'qr_code_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta('tenantId');
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [qrCodeId, tenantId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'revoked_qr_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RevokedQrCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('qr_code_id')) {
      context.handle(
        _qrCodeIdMeta,
        qrCodeId.isAcceptableOrUnknown(data['qr_code_id']!, _qrCodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_qrCodeIdMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {qrCodeId};
  @override
  RevokedQrCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RevokedQrCode(
      qrCodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_code_id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
    );
  }

  @override
  $RevokedQrCodesTable createAlias(String alias) {
    return $RevokedQrCodesTable(attachedDatabase, alias);
  }
}

class RevokedQrCode extends DataClass implements Insertable<RevokedQrCode> {
  final String qrCodeId;
  final String tenantId;
  const RevokedQrCode({required this.qrCodeId, required this.tenantId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['qr_code_id'] = Variable<String>(qrCodeId);
    map['tenant_id'] = Variable<String>(tenantId);
    return map;
  }

  RevokedQrCodesCompanion toCompanion(bool nullToAbsent) {
    return RevokedQrCodesCompanion(qrCodeId: Value(qrCodeId), tenantId: Value(tenantId));
  }

  factory RevokedQrCode.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RevokedQrCode(
      qrCodeId: serializer.fromJson<String>(json['qrCodeId']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'qrCodeId': serializer.toJson<String>(qrCodeId),
      'tenantId': serializer.toJson<String>(tenantId),
    };
  }

  RevokedQrCode copyWith({String? qrCodeId, String? tenantId}) =>
      RevokedQrCode(qrCodeId: qrCodeId ?? this.qrCodeId, tenantId: tenantId ?? this.tenantId);
  RevokedQrCode copyWithCompanion(RevokedQrCodesCompanion data) {
    return RevokedQrCode(
      qrCodeId: data.qrCodeId.present ? data.qrCodeId.value : this.qrCodeId,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RevokedQrCode(')
          ..write('qrCodeId: $qrCodeId, ')
          ..write('tenantId: $tenantId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(qrCodeId, tenantId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RevokedQrCode &&
          other.qrCodeId == this.qrCodeId &&
          other.tenantId == this.tenantId);
}

class RevokedQrCodesCompanion extends UpdateCompanion<RevokedQrCode> {
  final Value<String> qrCodeId;
  final Value<String> tenantId;
  final Value<int> rowid;
  const RevokedQrCodesCompanion({
    this.qrCodeId = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RevokedQrCodesCompanion.insert({
    required String qrCodeId,
    required String tenantId,
    this.rowid = const Value.absent(),
  }) : qrCodeId = Value(qrCodeId),
       tenantId = Value(tenantId);
  static Insertable<RevokedQrCode> custom({
    Expression<String>? qrCodeId,
    Expression<String>? tenantId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (qrCodeId != null) 'qr_code_id': qrCodeId,
      if (tenantId != null) 'tenant_id': tenantId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RevokedQrCodesCompanion copyWith({
    Value<String>? qrCodeId,
    Value<String>? tenantId,
    Value<int>? rowid,
  }) {
    return RevokedQrCodesCompanion(
      qrCodeId: qrCodeId ?? this.qrCodeId,
      tenantId: tenantId ?? this.tenantId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (qrCodeId.present) {
      map['qr_code_id'] = Variable<String>(qrCodeId.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RevokedQrCodesCompanion(')
          ..write('qrCodeId: $qrCodeId, ')
          ..write('tenantId: $tenantId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSettingsTable extends LocalSettings with TableInfo<$LocalSettingsTable, LocalSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LocalSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSetting(
      key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalSettingsTable createAlias(String alias) {
    return $LocalSettingsTable(attachedDatabase, alias);
  }
}

class LocalSetting extends DataClass implements Insertable<LocalSetting> {
  final String key;
  final String value;
  const LocalSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory LocalSetting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalSetting copyWith({String? key, String? value}) =>
      LocalSetting(key: key ?? this.key, value: value ?? this.value);
  LocalSetting copyWithCompanion(LocalSettingsCompanion data) {
    return LocalSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSetting && other.key == this.key && other.value == this.value);
}

class LocalSettingsCompanion extends UpdateCompanion<LocalSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const LocalSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<LocalSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSettingsCompanion copyWith({Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return LocalSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OutboxEventsTable outboxEvents = $OutboxEventsTable(this);
  late final $SigningKeysTable signingKeys = $SigningKeysTable(this);
  late final $RevokedQrCodesTable revokedQrCodes = $RevokedQrCodesTable(this);
  late final $LocalSettingsTable localSettings = $LocalSettingsTable(this);
  late final Index outboxPendingIx = Index(
    'outbox_pending_ix',
    'CREATE INDEX outbox_pending_ix ON outbox_events (status_code, occurred_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    outboxEvents,
    signingKeys,
    revokedQrCodes,
    localSettings,
    outboxPendingIx,
  ];
  @override
  DriftDatabaseOptions get options => const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$OutboxEventsTableCreateCompanionBuilder = OutboxEventsCompanion Function({
  required String id,
  required String kindCode,
  required DateTime occurredAt,
  required String payloadJson,
  required String statusCode,
  Value<String?> rejectionReasonCode,
  Value<String?> batchId,
  Value<int> attempts,
  Value<DateTime?> deliveredAt,
  Value<int> rowid,
});
typedef $$OutboxEventsTableUpdateCompanionBuilder = OutboxEventsCompanion Function({
  Value<String> id,
  Value<String> kindCode,
  Value<DateTime> occurredAt,
  Value<String> payloadJson,
  Value<String> statusCode,
  Value<String?> rejectionReasonCode,
  Value<String?> batchId,
  Value<int> attempts,
  Value<DateTime?> deliveredAt,
  Value<int> rowid,
});

class $$OutboxEventsTableFilterComposer extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get kindCode =>
      $composableBuilder(column: $table.kindCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get statusCode =>
      $composableBuilder(column: $table.statusCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rejectionReasonCode => $composableBuilder(
    column: $table.rejectionReasonCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deliveredAt =>
      $composableBuilder(column: $table.deliveredAt, builder: (column) => ColumnFilters(column));
}

class $$OutboxEventsTableOrderingComposer extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get kindCode =>
      $composableBuilder(column: $table.kindCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get statusCode =>
      $composableBuilder(column: $table.statusCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rejectionReasonCode => $composableBuilder(
    column: $table.rejectionReasonCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deliveredAt =>
      $composableBuilder(column: $table.deliveredAt, builder: (column) => ColumnOrderings(column));
}

class $$OutboxEventsTableAnnotationComposer extends Composer<_$AppDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kindCode =>
      $composableBuilder(column: $table.kindCode, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt =>
      $composableBuilder(column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<String> get payloadJson =>
      $composableBuilder(column: $table.payloadJson, builder: (column) => column);

  GeneratedColumn<String> get statusCode =>
      $composableBuilder(column: $table.statusCode, builder: (column) => column);

  GeneratedColumn<String> get rejectionReasonCode =>
      $composableBuilder(column: $table.rejectionReasonCode, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get deliveredAt =>
      $composableBuilder(column: $table.deliveredAt, builder: (column) => column);
}

class $$OutboxEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OutboxEventsTable,
          OutboxEvent,
          $$OutboxEventsTableFilterComposer,
          $$OutboxEventsTableOrderingComposer,
          $$OutboxEventsTableAnnotationComposer,
          $$OutboxEventsTableCreateCompanionBuilder,
          $$OutboxEventsTableUpdateCompanionBuilder,
          (OutboxEvent, BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEvent>),
          OutboxEvent,
          PrefetchHooks Function()
        > {
  $$OutboxEventsTableTableManager(_$AppDatabase db, $OutboxEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$OutboxEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$OutboxEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> kindCode = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> statusCode = const Value.absent(),
                Value<String?> rejectionReasonCode = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion(
                id: id,
                kindCode: kindCode,
                occurredAt: occurredAt,
                payloadJson: payloadJson,
                statusCode: statusCode,
                rejectionReasonCode: rejectionReasonCode,
                batchId: batchId,
                attempts: attempts,
                deliveredAt: deliveredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String kindCode,
                required DateTime occurredAt,
                required String payloadJson,
                required String statusCode,
                Value<String?> rejectionReasonCode = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> deliveredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion.insert(
                id: id,
                kindCode: kindCode,
                occurredAt: occurredAt,
                payloadJson: payloadJson,
                statusCode: statusCode,
                rejectionReasonCode: rejectionReasonCode,
                batchId: batchId,
                attempts: attempts,
                deliveredAt: deliveredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxEventsTable, OutboxEvent>(table),
                  BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEvent>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OutboxEventsTable,
      OutboxEvent,
      $$OutboxEventsTableFilterComposer,
      $$OutboxEventsTableOrderingComposer,
      $$OutboxEventsTableAnnotationComposer,
      $$OutboxEventsTableCreateCompanionBuilder,
      $$OutboxEventsTableUpdateCompanionBuilder,
      (OutboxEvent, BaseReferences<_$AppDatabase, $OutboxEventsTable, OutboxEvent>),
      OutboxEvent,
      PrefetchHooks Function()
    >;
typedef $$SigningKeysTableCreateCompanionBuilder = SigningKeysCompanion Function({
  required String tenantId,
  required String keyId,
  required String algorithm,
  required Uint8List publicKey,
  Value<DateTime?> retiredAt,
  Value<int> rowid,
});
typedef $$SigningKeysTableUpdateCompanionBuilder = SigningKeysCompanion Function({
  Value<String> tenantId,
  Value<String> keyId,
  Value<String> algorithm,
  Value<Uint8List> publicKey,
  Value<DateTime?> retiredAt,
  Value<int> rowid,
});

class $$SigningKeysTableFilterComposer extends Composer<_$AppDatabase, $SigningKeysTable> {
  $$SigningKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get keyId =>
      $composableBuilder(column: $table.keyId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => ColumnFilters(column));
}

class $$SigningKeysTableOrderingComposer extends Composer<_$AppDatabase, $SigningKeysTable> {
  $$SigningKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get keyId =>
      $composableBuilder(column: $table.keyId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => ColumnOrderings(column));
}

class $$SigningKeysTableAnnotationComposer extends Composer<_$AppDatabase, $SigningKeysTable> {
  $$SigningKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get keyId =>
      $composableBuilder(column: $table.keyId, builder: (column) => column);

  GeneratedColumn<String> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<DateTime> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => column);
}

class $$SigningKeysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SigningKeysTable,
          SigningKey,
          $$SigningKeysTableFilterComposer,
          $$SigningKeysTableOrderingComposer,
          $$SigningKeysTableAnnotationComposer,
          $$SigningKeysTableCreateCompanionBuilder,
          $$SigningKeysTableUpdateCompanionBuilder,
          (SigningKey, BaseReferences<_$AppDatabase, $SigningKeysTable, SigningKey>),
          SigningKey,
          PrefetchHooks Function()
        > {
  $$SigningKeysTableTableManager(_$AppDatabase db, $SigningKeysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$SigningKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$SigningKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SigningKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tenantId = const Value.absent(),
                Value<String> keyId = const Value.absent(),
                Value<String> algorithm = const Value.absent(),
                Value<Uint8List> publicKey = const Value.absent(),
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SigningKeysCompanion(
                tenantId: tenantId,
                keyId: keyId,
                algorithm: algorithm,
                publicKey: publicKey,
                retiredAt: retiredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tenantId,
                required String keyId,
                required String algorithm,
                required Uint8List publicKey,
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SigningKeysCompanion.insert(
                tenantId: tenantId,
                keyId: keyId,
                algorithm: algorithm,
                publicKey: publicKey,
                retiredAt: retiredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SigningKeysTable, SigningKey>(table),
                  BaseReferences<_$AppDatabase, $SigningKeysTable, SigningKey>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SigningKeysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SigningKeysTable,
      SigningKey,
      $$SigningKeysTableFilterComposer,
      $$SigningKeysTableOrderingComposer,
      $$SigningKeysTableAnnotationComposer,
      $$SigningKeysTableCreateCompanionBuilder,
      $$SigningKeysTableUpdateCompanionBuilder,
      (SigningKey, BaseReferences<_$AppDatabase, $SigningKeysTable, SigningKey>),
      SigningKey,
      PrefetchHooks Function()
    >;
typedef $$RevokedQrCodesTableCreateCompanionBuilder = RevokedQrCodesCompanion Function({
  required String qrCodeId,
  required String tenantId,
  Value<int> rowid,
});
typedef $$RevokedQrCodesTableUpdateCompanionBuilder = RevokedQrCodesCompanion Function({
  Value<String> qrCodeId,
  Value<String> tenantId,
  Value<int> rowid,
});

class $$RevokedQrCodesTableFilterComposer extends Composer<_$AppDatabase, $RevokedQrCodesTable> {
  $$RevokedQrCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get qrCodeId =>
      $composableBuilder(column: $table.qrCodeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => ColumnFilters(column));
}

class $$RevokedQrCodesTableOrderingComposer extends Composer<_$AppDatabase, $RevokedQrCodesTable> {
  $$RevokedQrCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get qrCodeId =>
      $composableBuilder(column: $table.qrCodeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => ColumnOrderings(column));
}

class $$RevokedQrCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RevokedQrCodesTable> {
  $$RevokedQrCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get qrCodeId =>
      $composableBuilder(column: $table.qrCodeId, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);
}

class $$RevokedQrCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RevokedQrCodesTable,
          RevokedQrCode,
          $$RevokedQrCodesTableFilterComposer,
          $$RevokedQrCodesTableOrderingComposer,
          $$RevokedQrCodesTableAnnotationComposer,
          $$RevokedQrCodesTableCreateCompanionBuilder,
          $$RevokedQrCodesTableUpdateCompanionBuilder,
          (RevokedQrCode, BaseReferences<_$AppDatabase, $RevokedQrCodesTable, RevokedQrCode>),
          RevokedQrCode,
          PrefetchHooks Function()
        > {
  $$RevokedQrCodesTableTableManager(_$AppDatabase db, $RevokedQrCodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RevokedQrCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RevokedQrCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RevokedQrCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> qrCodeId = const Value.absent(),
            Value<String> tenantId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => RevokedQrCodesCompanion(qrCodeId: qrCodeId, tenantId: tenantId, rowid: rowid),
          createCompanionCallback:
              ({
                required String qrCodeId,
                required String tenantId,
                Value<int> rowid = const Value.absent(),
              }) => RevokedQrCodesCompanion.insert(
                qrCodeId: qrCodeId,
                tenantId: tenantId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RevokedQrCodesTable, RevokedQrCode>(table),
                  BaseReferences<_$AppDatabase, $RevokedQrCodesTable, RevokedQrCode>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RevokedQrCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RevokedQrCodesTable,
      RevokedQrCode,
      $$RevokedQrCodesTableFilterComposer,
      $$RevokedQrCodesTableOrderingComposer,
      $$RevokedQrCodesTableAnnotationComposer,
      $$RevokedQrCodesTableCreateCompanionBuilder,
      $$RevokedQrCodesTableUpdateCompanionBuilder,
      (RevokedQrCode, BaseReferences<_$AppDatabase, $RevokedQrCodesTable, RevokedQrCode>),
      RevokedQrCode,
      PrefetchHooks Function()
    >;
typedef $$LocalSettingsTableCreateCompanionBuilder = LocalSettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$LocalSettingsTableUpdateCompanionBuilder = LocalSettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$LocalSettingsTableFilterComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$LocalSettingsTableOrderingComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$LocalSettingsTableAnnotationComposer extends Composer<_$AppDatabase, $LocalSettingsTable> {
  $$LocalSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSettingsTable,
          LocalSetting,
          $$LocalSettingsTableFilterComposer,
          $$LocalSettingsTableOrderingComposer,
          $$LocalSettingsTableAnnotationComposer,
          $$LocalSettingsTableCreateCompanionBuilder,
          $$LocalSettingsTableUpdateCompanionBuilder,
          (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
          LocalSetting,
          PrefetchHooks Function()
        > {
  $$LocalSettingsTableTableManager(_$AppDatabase db, $LocalSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$LocalSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => LocalSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => LocalSettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocalSettingsTable, LocalSetting>(table),
                  BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSettingsTable,
      LocalSetting,
      $$LocalSettingsTableFilterComposer,
      $$LocalSettingsTableOrderingComposer,
      $$LocalSettingsTableAnnotationComposer,
      $$LocalSettingsTableCreateCompanionBuilder,
      $$LocalSettingsTableUpdateCompanionBuilder,
      (LocalSetting, BaseReferences<_$AppDatabase, $LocalSettingsTable, LocalSetting>),
      LocalSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OutboxEventsTableTableManager get outboxEvents =>
      $$OutboxEventsTableTableManager(_db, _db.outboxEvents);
  $$SigningKeysTableTableManager get signingKeys =>
      $$SigningKeysTableTableManager(_db, _db.signingKeys);
  $$RevokedQrCodesTableTableManager get revokedQrCodes =>
      $$RevokedQrCodesTableTableManager(_db, _db.revokedQrCodes);
  $$LocalSettingsTableTableManager get localSettings =>
      $$LocalSettingsTableTableManager(_db, _db.localSettings);
}
