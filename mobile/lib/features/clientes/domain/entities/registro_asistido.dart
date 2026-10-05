import 'ficha_cliente.dart';

/// Tipo de documento del catálogo (CC, TI, RC, CE, PPT, PASSPORT).
class TipoDocumento {
  const TipoDocumento({required this.codigo, required this.nombre, this.patron});

  final String codigo;
  final String nombre;

  /// Expresión regular que debe cumplir el número; null si no hay.
  final String? patron;
}

/// La política de datos "en corto" para leerla en voz alta antes de registrar.
class PoliticaEnCorto {
  const PoliticaEnCorto({
    required this.id,
    required this.version,
    required this.anotamos,
    required this.nuncaHacemos,
    required this.paraQue,
  });

  final String id;
  final String version;
  final List<String> anotamos;
  final List<String> nuncaHacemos;
  final String paraQue;
}

/// Lo que el cajero llena en el registro asistido (HU-04-04).
class DatosRegistroAsistido {
  const DatosRegistroAsistido({
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.politicaVersionId,
    this.nombres,
    this.apellidos,
    this.celular,
    this.celularCompartido = false,
  });

  final String tipoDocumento;
  final String numeroDocumento;
  final String politicaVersionId;
  final String? nombres;
  final String? apellidos;
  final String? celular;

  /// true cuando el celular ya es de otra cuenta y la familia lo comparte.
  final bool celularCompartido;

  DatosRegistroAsistido conCelularCompartido() => DatosRegistroAsistido(
    tipoDocumento: tipoDocumento,
    numeroDocumento: numeroDocumento,
    politicaVersionId: politicaVersionId,
    nombres: nombres,
    apellidos: apellidos,
    celular: celular,
    celularCompartido: true,
  );
}

/// Resultado del registro: la ficha y, si se creó su cuenta, el PIN para dictarle.
class RegistroHecho {
  const RegistroHecho({required this.ficha, required this.vinculado, this.pinBienvenida});

  final FichaCliente ficha;

  /// true si la persona ya estaba en VECI y solo se afilió a este negocio.
  final bool vinculado;
  final String? pinBienvenida;
}
