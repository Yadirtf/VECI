//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class MisTiqueterasResponse {
  /// Returns a new [MisTiqueterasResponse] instance.
  MisTiqueterasResponse({
    required this.comercio,
    required this.comercioId,
    this.saldos = const [],
    this.tiqueteras = const [],
  });

  String comercio;

  String comercioId;

  List<SaldoResponse> saldos;

  List<TiqueteraResponse> tiqueteras;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MisTiqueterasResponse &&
    other.comercio == comercio &&
    other.comercioId == comercioId &&
    _deepEquality.equals(other.saldos, saldos) &&
    _deepEquality.equals(other.tiqueteras, tiqueteras);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (comercio.hashCode) +
    (comercioId.hashCode) +
    (saldos.hashCode) +
    (tiqueteras.hashCode);

  @override
  String toString() => 'MisTiqueterasResponse[comercio=$comercio, comercioId=$comercioId, saldos=$saldos, tiqueteras=$tiqueteras]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'comercio'] = this.comercio;
      json[r'comercioId'] = this.comercioId;
      json[r'saldos'] = this.saldos;
      json[r'tiqueteras'] = this.tiqueteras;
    return json;
  }

  /// Returns a new [MisTiqueterasResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MisTiqueterasResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'comercio'), 'Required key "MisTiqueterasResponse[comercio]" is missing from JSON.');
        assert(json[r'comercio'] != null, 'Required key "MisTiqueterasResponse[comercio]" has a null value in JSON.');
        assert(json.containsKey(r'comercioId'), 'Required key "MisTiqueterasResponse[comercioId]" is missing from JSON.');
        assert(json[r'comercioId'] != null, 'Required key "MisTiqueterasResponse[comercioId]" has a null value in JSON.');
        assert(json.containsKey(r'saldos'), 'Required key "MisTiqueterasResponse[saldos]" is missing from JSON.');
        assert(json[r'saldos'] != null, 'Required key "MisTiqueterasResponse[saldos]" has a null value in JSON.');
        assert(json.containsKey(r'tiqueteras'), 'Required key "MisTiqueterasResponse[tiqueteras]" is missing from JSON.');
        assert(json[r'tiqueteras'] != null, 'Required key "MisTiqueterasResponse[tiqueteras]" has a null value in JSON.');
        return true;
      }());

      return MisTiqueterasResponse(
        comercio: mapValueOfType<String>(json, r'comercio')!,
        comercioId: mapValueOfType<String>(json, r'comercioId')!,
        saldos: SaldoResponse.listFromJson(json[r'saldos']),
        tiqueteras: TiqueteraResponse.listFromJson(json[r'tiqueteras']),
      );
    }
    return null;
  }

  static List<MisTiqueterasResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MisTiqueterasResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MisTiqueterasResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MisTiqueterasResponse> mapFromJson(dynamic json) {
    final map = <String, MisTiqueterasResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MisTiqueterasResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MisTiqueterasResponse-objects as value to a dart map
  static Map<String, List<MisTiqueterasResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MisTiqueterasResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MisTiqueterasResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'comercio',
    'comercioId',
    'saldos',
    'tiqueteras',
  };
}

