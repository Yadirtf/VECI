//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class ComercioRegistradoResponse {
  /// Returns a new [ComercioRegistradoResponse] instance.
  ComercioRegistradoResponse({
    required this.comercioId,
    this.pinTemporal,
    required this.slug,
  });

  String comercioId;

  /// Solo al registrar a nombre de otra persona sin PIN propio. Se muestra una vez.
  String? pinTemporal;

  String slug;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ComercioRegistradoResponse &&
    other.comercioId == comercioId &&
    other.pinTemporal == pinTemporal &&
    other.slug == slug;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (comercioId.hashCode) +
    (pinTemporal == null ? 0 : pinTemporal!.hashCode) +
    (slug.hashCode);

  @override
  String toString() => 'ComercioRegistradoResponse[comercioId=$comercioId, pinTemporal=$pinTemporal, slug=$slug]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'comercioId'] = this.comercioId;
    if (this.pinTemporal != null) {
      json[r'pinTemporal'] = this.pinTemporal;
    } else {
      json[r'pinTemporal'] = null;
    }
      json[r'slug'] = this.slug;
    return json;
  }

  /// Returns a new [ComercioRegistradoResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ComercioRegistradoResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'comercioId'), 'Required key "ComercioRegistradoResponse[comercioId]" is missing from JSON.');
        assert(json[r'comercioId'] != null, 'Required key "ComercioRegistradoResponse[comercioId]" has a null value in JSON.');
        assert(json.containsKey(r'slug'), 'Required key "ComercioRegistradoResponse[slug]" is missing from JSON.');
        assert(json[r'slug'] != null, 'Required key "ComercioRegistradoResponse[slug]" has a null value in JSON.');
        return true;
      }());

      return ComercioRegistradoResponse(
        comercioId: mapValueOfType<String>(json, r'comercioId')!,
        pinTemporal: mapValueOfType<String>(json, r'pinTemporal'),
        slug: mapValueOfType<String>(json, r'slug')!,
      );
    }
    return null;
  }

  static List<ComercioRegistradoResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ComercioRegistradoResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ComercioRegistradoResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ComercioRegistradoResponse> mapFromJson(dynamic json) {
    final map = <String, ComercioRegistradoResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ComercioRegistradoResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ComercioRegistradoResponse-objects as value to a dart map
  static Map<String, List<ComercioRegistradoResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ComercioRegistradoResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ComercioRegistradoResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'comercioId',
    'slug',
  };
}

