/// Tipo de negocio del catálogo y los servicios con que nace.
class TipoDeNegocio {
  const TipoDeNegocio({required this.codigo, required this.nombre, required this.servicios});

  final String codigo;
  final String nombre;
  final List<String> servicios;
}

/// Una pregunta por pantalla, como en el panel: se contesta entre pedido y pedido.
enum PasoAlta { nombre, tipo, documento, contacto, letrero }

/// Lo que se lleva escrito para registrar el negocio.
class BorradorAlta {
  const BorradorAlta({
    this.nombre = '',
    this.tipoNegocio = '',
    this.esNit = true,
    this.documento = '',
    this.celular = '',
  });

  final String nombre;
  final String tipoNegocio;
  final bool esNit;

  /// Solo los números escritos (sin el dígito de verificación del NIT).
  final String documento;
  final String celular;

  BorradorAlta copiar({
    String? nombre,
    String? tipoNegocio,
    bool? esNit,
    String? documento,
    String? celular,
  }) => BorradorAlta(
    nombre: nombre ?? this.nombre,
    tipoNegocio: tipoNegocio ?? this.tipoNegocio,
    esNit: esNit ?? this.esNit,
    documento: documento ?? this.documento,
    celular: celular ?? this.celular,
  );
}
