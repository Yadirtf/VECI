//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of veci_api;

class PerfilComercioResponse {
  /// Returns a new [PerfilComercioResponse] instance.
  PerfilComercioResponse({
    required this.abierto,
    required this.avance,
    this.camino = const [],
    required this.comercioId,
    required this.contacto,
    required this.documento,
    required this.estado,
    this.logoUrl,
    required this.nombre,
    this.plan,
    required this.puedeAbrir,
    required this.slug,
    required this.tipoNegocio,
  });

  /// Ya vende y registra consumos
  bool abierto;

  AvanceResponse avance;

  List<PasoResponse> camino;

  String comercioId;

  ContactoResponse contacto;

  DocumentoResponse documento;

  String estado;

  String? logoUrl;

  String nombre;

  PlanResponse? plan;

  bool puedeAbrir;

  String slug;

  String tipoNegocio;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PerfilComercioResponse &&
    other.abierto == abierto &&
    other.avance == avance &&
    _deepEquality.equals(other.camino, camino) &&
    other.comercioId == comercioId &&
    other.contacto == contacto &&
    other.documento == documento &&
    other.estado == estado &&
    other.logoUrl == logoUrl &&
    other.nombre == nombre &&
    other.plan == plan &&
    other.puedeAbrir == puedeAbrir &&
    other.slug == slug &&
    other.tipoNegocio == tipoNegocio;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (abierto.hashCode) +
    (avance.hashCode) +
    (camino.hashCode) +
    (comercioId.hashCode) +
    (contacto.hashCode) +
    (documento.hashCode) +
    (estado.hashCode) +
    (logoUrl == null ? 0 : logoUrl!.hashCode) +
    (nombre.hashCode) +
    (plan == null ? 0 : plan!.hashCode) +
    (puedeAbrir.hashCode) +
    (slug.hashCode) +
    (tipoNegocio.hashCode);

  @override
  String toString() => 'PerfilComercioResponse[abierto=$abierto, avance=$avance, camino=$camino, comercioId=$comercioId, contacto=$contacto, documento=$documento, estado=$estado, logoUrl=$logoUrl, nombre=$nombre, plan=$plan, puedeAbrir=$puedeAbrir, slug=$slug, tipoNegocio=$tipoNegocio]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'abierto'] = this.abierto;
      json[r'avance'] = this.avance;
      json[r'camino'] = this.camino;
      json[r'comercioId'] = this.comercioId;
      json[r'contacto'] = this.contacto;
      json[r'documento'] = this.documento;
      json[r'estado'] = this.estado;
    if (this.logoUrl != null) {
      json[r'logoUrl'] = this.logoUrl;
    } else {
      json[r'logoUrl'] = null;
    }
      json[r'nombre'] = this.nombre;
    if (this.plan != null) {
      json[r'plan'] = this.plan;
    } else {
      json[r'plan'] = null;
    }
      json[r'puedeAbrir'] = this.puedeAbrir;
      json[r'slug'] = this.slug;
      json[r'tipoNegocio'] = this.tipoNegocio;
    return json;
  }

  /// Returns a new [PerfilComercioResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PerfilComercioResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        assert(json.containsKey(r'abierto'), 'Required key "PerfilComercioResponse[abierto]" is missing from JSON.');
        assert(json[r'abierto'] != null, 'Required key "PerfilComercioResponse[abierto]" has a null value in JSON.');
        assert(json.containsKey(r'avance'), 'Required key "PerfilComercioResponse[avance]" is missing from JSON.');
        assert(json[r'avance'] != null, 'Required key "PerfilComercioResponse[avance]" has a null value in JSON.');
        assert(json.containsKey(r'camino'), 'Required key "PerfilComercioResponse[camino]" is missing from JSON.');
        assert(json[r'camino'] != null, 'Required key "PerfilComercioResponse[camino]" has a null value in JSON.');
        assert(json.containsKey(r'comercioId'), 'Required key "PerfilComercioResponse[comercioId]" is missing from JSON.');
        assert(json[r'comercioId'] != null, 'Required key "PerfilComercioResponse[comercioId]" has a null value in JSON.');
        assert(json.containsKey(r'contacto'), 'Required key "PerfilComercioResponse[contacto]" is missing from JSON.');
        assert(json[r'contacto'] != null, 'Required key "PerfilComercioResponse[contacto]" has a null value in JSON.');
        assert(json.containsKey(r'documento'), 'Required key "PerfilComercioResponse[documento]" is missing from JSON.');
        assert(json[r'documento'] != null, 'Required key "PerfilComercioResponse[documento]" has a null value in JSON.');
        assert(json.containsKey(r'estado'), 'Required key "PerfilComercioResponse[estado]" is missing from JSON.');
        assert(json[r'estado'] != null, 'Required key "PerfilComercioResponse[estado]" has a null value in JSON.');
        assert(json.containsKey(r'nombre'), 'Required key "PerfilComercioResponse[nombre]" is missing from JSON.');
        assert(json[r'nombre'] != null, 'Required key "PerfilComercioResponse[nombre]" has a null value in JSON.');
        assert(json.containsKey(r'puedeAbrir'), 'Required key "PerfilComercioResponse[puedeAbrir]" is missing from JSON.');
        assert(json[r'puedeAbrir'] != null, 'Required key "PerfilComercioResponse[puedeAbrir]" has a null value in JSON.');
        assert(json.containsKey(r'slug'), 'Required key "PerfilComercioResponse[slug]" is missing from JSON.');
        assert(json[r'slug'] != null, 'Required key "PerfilComercioResponse[slug]" has a null value in JSON.');
        assert(json.containsKey(r'tipoNegocio'), 'Required key "PerfilComercioResponse[tipoNegocio]" is missing from JSON.');
        assert(json[r'tipoNegocio'] != null, 'Required key "PerfilComercioResponse[tipoNegocio]" has a null value in JSON.');
        return true;
      }());

      return PerfilComercioResponse(
        abierto: mapValueOfType<bool>(json, r'abierto')!,
        avance: AvanceResponse.fromJson(json[r'avance'])!,
        camino: PasoResponse.listFromJson(json[r'camino']),
        comercioId: mapValueOfType<String>(json, r'comercioId')!,
        contacto: ContactoResponse.fromJson(json[r'contacto'])!,
        documento: DocumentoResponse.fromJson(json[r'documento'])!,
        estado: mapValueOfType<String>(json, r'estado')!,
        logoUrl: mapValueOfType<String>(json, r'logoUrl'),
        nombre: mapValueOfType<String>(json, r'nombre')!,
        plan: PlanResponse.fromJson(json[r'plan']),
        puedeAbrir: mapValueOfType<bool>(json, r'puedeAbrir')!,
        slug: mapValueOfType<String>(json, r'slug')!,
        tipoNegocio: mapValueOfType<String>(json, r'tipoNegocio')!,
      );
    }
    return null;
  }

  static List<PerfilComercioResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PerfilComercioResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PerfilComercioResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PerfilComercioResponse> mapFromJson(dynamic json) {
    final map = <String, PerfilComercioResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PerfilComercioResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PerfilComercioResponse-objects as value to a dart map
  static Map<String, List<PerfilComercioResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PerfilComercioResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PerfilComercioResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'abierto',
    'avance',
    'camino',
    'comercioId',
    'contacto',
    'documento',
    'estado',
    'nombre',
    'puedeAbrir',
    'slug',
    'tipoNegocio',
  };
}

