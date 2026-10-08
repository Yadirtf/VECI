/// Tipo de negocio del catálogo y los servicios con que nace.
class TipoDeNegocio {
  const TipoDeNegocio({required this.codigo, required this.nombre, required this.servicios});

  final String codigo;
  final String nombre;
  final List<String> servicios;
}

/// Municipio donde VECI ya presta el servicio (por ahora, Mocoa).
class Municipio {
  const Municipio({required this.id, required this.nombre});

  final int id;
  final String nombre;
}

/// Lo que se necesita del servidor para hacer las preguntas.
class CatalogosAlta {
  const CatalogosAlta({required this.tipos, required this.municipios});

  final List<TipoDeNegocio> tipos;
  final List<Municipio> municipios;
}

/// Una pregunta por pantalla, como en el panel: se contesta entre pedido y pedido.
enum PasoAlta { nombre, tipo, documento, contacto, lugar, letrero }

/// Lo que se lleva escrito para registrar el negocio.
class BorradorAlta {
  const BorradorAlta({
    this.nombre = '',
    this.tipoNegocio = '',
    this.esNit = true,
    this.documento = '',
    this.celular = '',
    this.municipioId,
  });

  final String nombre;
  final String tipoNegocio;
  final bool esNit;

  /// Solo los números escritos (sin el dígito de verificación del NIT).
  final String documento;
  final String celular;

  /// Municipio del catálogo; VECI solo recibe negocios donde ya presta el servicio.
  final int? municipioId;

  BorradorAlta copiar({
    String? nombre,
    String? tipoNegocio,
    bool? esNit,
    String? documento,
    String? celular,
    int? municipioId,
  }) => BorradorAlta(
    nombre: nombre ?? this.nombre,
    tipoNegocio: tipoNegocio ?? this.tipoNegocio,
    esNit: esNit ?? this.esNit,
    documento: documento ?? this.documento,
    celular: celular ?? this.celular,
    municipioId: municipioId ?? this.municipioId,
  );
}
