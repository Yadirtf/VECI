//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class InvitacionResponse {
  /// Returns a new [InvitacionResponse] instance.
  InvitacionResponse({
    required this.membresiaId,
    this.pinTemporal,
  });

  String membresiaId;

  /// Se muestra una sola vez. null si la persona ya tenía PIN propio.
  String? pinTemporal;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InvitacionResponse &&
    other.membresiaId == membresiaId &&
    other.pinTemporal == pinTemporal;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (membresiaId.hashCode) +
    (pinTemporal == null ? 0 : pinTemporal!.hashCode);

  @override
  String toString() => 'InvitacionResponse[membresiaId=$membresiaId, pinTemporal=$pinTemporal]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'membresiaId'] = this.membresiaId;
    if (this.pinTemporal != null) {
      json[r'pinTemporal'] = this.pinTemporal;
    } else {
      json[r'pinTemporal'] = null;
    }
    return json;
  }

  /// Returns a new [InvitacionResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InvitacionResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'membresiaId'), 'Required key "InvitacionResponse[membresiaId]" is missing from JSON.');
        assert(json[r'membresiaId'] != null, 'Required key "InvitacionResponse[membresiaId]" has a null value in JSON.');
        return true;
      }());

      return InvitacionResponse(
        membresiaId: mapValueOfType<String>(json, r'membresiaId')!,
        pinTemporal: mapValueOfType<String>(json, r'pinTemporal'),
      );
    }
    return null;
  }

  static List<InvitacionResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InvitacionResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InvitacionResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InvitacionResponse> mapFromJson(dynamic json) {
    final map = <String, InvitacionResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InvitacionResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InvitacionResponse-objects as value to a dart map
  static Map<String, List<InvitacionResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InvitacionResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InvitacionResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'membresiaId',
  };
}

