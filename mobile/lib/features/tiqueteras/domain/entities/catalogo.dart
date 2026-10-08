/// Lo que se descuenta: almuerzo, desayuno, café…
class Unidad {
  const Unidad({required this.codigo, required this.singular, required this.plural});

  final String codigo;
  final String singular;
  final String plural;

  /// "1 almuerzo", "20 almuerzos".
  String de(int cantidad) => '$cantidad ${cantidad.abs() == 1 ? singular : plural}';
}

/// Una tiquetera de la pizarra que la caja puede vender (HU-05-01).
class TipoEnVenta {
  const TipoEnVenta({
    required this.tipoId,
    required this.nombre,
    required this.unidad,
    required this.unidades,
    required this.precio,
    required this.vigenciaDias,
  });

  final String tipoId;
  final String nombre;
  final Unidad unidad;
  final int unidades;

  /// Pesos, sin centavos.
  final int precio;
  final int vigenciaDias;
}

class Canal {
  const Canal({required this.codigo, required this.nombre});

  final String codigo;
  final String nombre;
}

/// Efectivo o transferencia; la transferencia dice por dónde llegó (Nequi, Daviplata…).
class MedioDePago {
  const MedioDePago({
    required this.codigo,
    required this.nombre,
    required this.necesitaCanal,
    this.canales = const [],
  });

  final String codigo;
  final String nombre;
  final bool necesitaCanal;
  final List<Canal> canales;
}

/// Lo que la caja guarda para vender sin internet (ADR-0004): tipos activos y medios.
class CatalogoDeVenta {
  const CatalogoDeVenta({
    required this.tipos,
    required this.medios,
    this.alDiaEn,
    this.sinSenal = false,
  });

  final List<TipoEnVenta> tipos;
  final List<MedioDePago> medios;

  /// Última vez que el servidor confirmó la copia.
  final DateTime? alDiaEn;
  final bool sinSenal;

  CatalogoDeVenta conSenal({required bool sinSenal}) =>
      CatalogoDeVenta(tipos: tipos, medios: medios, alDiaEn: alDiaEn, sinSenal: sinSenal);
}
