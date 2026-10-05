//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class DocumentoRequest {
  /// Returns a new [DocumentoRequest] instance.
  DocumentoRequest({
    required this.numeroDocumento,
    required this.tipoDocumento,
  });

  String numeroDocumento;

  /// Código del tipo de documento (catálogo)
  String tipoDocumento;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DocumentoRequest &&
    other.numeroDocumento == numeroDocumento &&
    other.tipoDocumento == tipoDocumento;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (numeroDocumento.hashCode) +
    (tipoDocumento.hashCode);

  @override
  String toString() => 'DocumentoRequest[numeroDocumento=$numeroDocumento, tipoDocumento=$tipoDocumento]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'numeroDocumento'] = this.numeroDocumento;
      json[r'tipoDocumento'] = this.tipoDocumento;
    return json;
  }

  /// Returns a new [DocumentoRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DocumentoRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'numeroDocumento'), 'Required key "DocumentoRequest[numeroDocumento]" is missing from JSON.');
        assert(json[r'numeroDocumento'] != null, 'Required key "DocumentoRequest[numeroDocumento]" has a null value in JSON.');
        assert(json.containsKey(r'tipoDocumento'), 'Required key "DocumentoRequest[tipoDocumento]" is missing from JSON.');
        assert(json[r'tipoDocumento'] != null, 'Required key "DocumentoRequest[tipoDocumento]" has a null value in JSON.');
        return true;
      }());

      return DocumentoRequest(
        numeroDocumento: mapValueOfType<String>(json, r'numeroDocumento')!,
        tipoDocumento: mapValueOfType<String>(json, r'tipoDocumento')!,
      );
    }
    return null;
  }

  static List<DocumentoRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DocumentoRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DocumentoRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DocumentoRequest> mapFromJson(dynamic json) {
    final map = <String, DocumentoRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DocumentoRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DocumentoRequest-objects as value to a dart map
  static Map<String, List<DocumentoRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DocumentoRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DocumentoRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'numeroDocumento',
    'tipoDocumento',
  };
}

