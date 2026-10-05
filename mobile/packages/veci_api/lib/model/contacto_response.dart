//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ContactoResponse {
  /// Returns a new [ContactoResponse] instance.
  ContactoResponse({
    this.celular,
    this.correo,
  });

  String? celular;

  String? correo;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ContactoResponse &&
    other.celular == celular &&
    other.correo == correo;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (celular == null ? 0 : celular!.hashCode) +
    (correo == null ? 0 : correo!.hashCode);

  @override
  String toString() => 'ContactoResponse[celular=$celular, correo=$correo]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.celular != null) {
      json[r'celular'] = this.celular;
    } else {
      json[r'celular'] = null;
    }
    if (this.correo != null) {
      json[r'correo'] = this.correo;
    } else {
      json[r'correo'] = null;
    }
    return json;
  }

  /// Returns a new [ContactoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ContactoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        return true;
      }());

      return ContactoResponse(
        celular: mapValueOfType<String>(json, r'celular'),
        correo: mapValueOfType<String>(json, r'correo'),
      );
    }
    return null;
  }

  static List<ContactoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ContactoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ContactoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ContactoResponse> mapFromJson(dynamic json) {
    final map = <String, ContactoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ContactoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ContactoResponse-objects as value to a dart map
  static Map<String, List<ContactoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ContactoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ContactoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}

