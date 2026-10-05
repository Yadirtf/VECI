/// Tipo de documento del catálogo. [patron] es la forma del número (null = cualquiera).
class TipoDocumento {
  const TipoDocumento({required this.codigo, required this.nombre, this.patron});

  final String codigo;
  final String nombre;
  final String? patron;
}

/// Una parte de la política: primero en palabras de vecino y debajo el texto legal.
class SeccionPolitica {
  const SeccionPolitica({
    required this.titulo,
    required this.enPalabrasDeVecino,
    required this.texto,
  });

  final String titulo;
  final String enPalabrasDeVecino;
  final String texto;
}

/// Política de datos vigente: el "en corto" para decidir y las secciones para leerla toda.
class PoliticaDeDatos {
  const PoliticaDeDatos({
    required this.id,
    required this.version,
    required this.anotamos,
    required this.nuncaHacemos,
    required this.paraQue,
    required this.secciones,
  });

  /// Se envía al aceptar: así queda cuál versión aceptó la persona.
  final String id;
  final String version;
  final List<String> anotamos;
  final List<String> nuncaHacemos;
  final String paraQue;
  final List<SeccionPolitica> secciones;
}

/// Una pregunta por pantalla, como una conversación (HU-04-01).
enum PasoRegistro { celular, nombre, documento, politica, pin }

/// Lo que la persona lleva escrito para crear su cuenta.
class BorradorRegistro {
  const BorradorRegistro({
    this.celular = '',
    this.nombres = '',
    this.apellidos = '',
    this.tipoDocumento = 'CC',
    this.numeroDocumento = '',
    this.pin = '',
    this.pinRepetido = '',
  });

  final String celular;
  final String nombres;

  /// Opcional.
  final String apellidos;
  final String tipoDocumento;
  final String numeroDocumento;
  final String pin;
  final String pinRepetido;

  BorradorRegistro copiar({
    String? celular,
    String? nombres,
    String? apellidos,
    String? tipoDocumento,
    String? numeroDocumento,
    String? pin,
    String? pinRepetido,
  }) => BorradorRegistro(
    celular: celular ?? this.celular,
    nombres: nombres ?? this.nombres,
    apellidos: apellidos ?? this.apellidos,
    tipoDocumento: tipoDocumento ?? this.tipoDocumento,
    numeroDocumento: numeroDocumento ?? this.numeroDocumento,
    pin: pin ?? this.pin,
    pinRepetido: pinRepetido ?? this.pinRepetido,
  );
}
