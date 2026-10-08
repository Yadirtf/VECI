//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class EstadoDeCuentaResponse {
  /// Returns a new [EstadoDeCuentaResponse] instance.
  EstadoDeCuentaResponse({
    required this.clienteId,
    this.movimientos = const [],
    this.saldos = const [],
    this.tiqueteras = const [],
  });

  String clienteId;

  /// Lo más reciente primero
  List<MovimientoResponse> movimientos;

  /// Saldo por unidad
  List<SaldoResponse> saldos;

  List<TiqueteraResponse> tiqueteras;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EstadoDeCuentaResponse &&
    other.clienteId == clienteId &&
    _deepEquality.equals(other.movimientos, movimientos) &&
    _deepEquality.equals(other.saldos, saldos) &&
    _deepEquality.equals(other.tiqueteras, tiqueteras);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (clienteId.hashCode) +
    (movimientos.hashCode) +
    (saldos.hashCode) +
    (tiqueteras.hashCode);

  @override
  String toString() => 'EstadoDeCuentaResponse[clienteId=$clienteId, movimientos=$movimientos, saldos=$saldos, tiqueteras=$tiqueteras]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'clienteId'] = this.clienteId;
      json[r'movimientos'] = this.movimientos;
      json[r'saldos'] = this.saldos;
      json[r'tiqueteras'] = this.tiqueteras;
    return json;
  }

  /// Returns a new [EstadoDeCuentaResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EstadoDeCuentaResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'clienteId'), 'Required key "EstadoDeCuentaResponse[clienteId]" is missing from JSON.');
        assert(json[r'clienteId'] != null, 'Required key "EstadoDeCuentaResponse[clienteId]" has a null value in JSON.');
        assert(json.containsKey(r'movimientos'), 'Required key "EstadoDeCuentaResponse[movimientos]" is missing from JSON.');
        assert(json[r'movimientos'] != null, 'Required key "EstadoDeCuentaResponse[movimientos]" has a null value in JSON.');
        assert(json.containsKey(r'saldos'), 'Required key "EstadoDeCuentaResponse[saldos]" is missing from JSON.');
        assert(json[r'saldos'] != null, 'Required key "EstadoDeCuentaResponse[saldos]" has a null value in JSON.');
        assert(json.containsKey(r'tiqueteras'), 'Required key "EstadoDeCuentaResponse[tiqueteras]" is missing from JSON.');
        assert(json[r'tiqueteras'] != null, 'Required key "EstadoDeCuentaResponse[tiqueteras]" has a null value in JSON.');
        return true;
      }());

      return EstadoDeCuentaResponse(
        clienteId: mapValueOfType<String>(json, r'clienteId')!,
        movimientos: MovimientoResponse.listFromJson(json[r'movimientos']),
        saldos: SaldoResponse.listFromJson(json[r'saldos']),
        tiqueteras: TiqueteraResponse.listFromJson(json[r'tiqueteras']),
      );
    }
    return null;
  }

  static List<EstadoDeCuentaResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EstadoDeCuentaResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EstadoDeCuentaResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EstadoDeCuentaResponse> mapFromJson(dynamic json) {
    final map = <String, EstadoDeCuentaResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EstadoDeCuentaResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EstadoDeCuentaResponse-objects as value to a dart map
  static Map<String, List<EstadoDeCuentaResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EstadoDeCuentaResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EstadoDeCuentaResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'clienteId',
    'movimientos',
    'saldos',
    'tiqueteras',
  };
}

