import 'catalogo.dart';

enum EstadoTiquetera {
  activa('ACTIVE'),
  agotada('DEPLETED'),
  vencida('EXPIRED'),
  anulada('VOIDED');

  const EstadoTiquetera(this.codigo);

  final String codigo;

  static EstadoTiquetera desde(String codigo) =>
      values.firstWhere((e) => e.codigo == codigo, orElse: () => activa);
}

/// Una tiquetera vendida: el cartón con sus casillas.
class Tiquetera {
  const Tiquetera({
    required this.tiqueteraId,
    required this.nombre,
    required this.unidad,
    required this.compradas,
    required this.saldo,
    required this.estado,
    required this.compradaEn,
    required this.ultimoDia,
    required this.vigente,
    this.turno,
  });

  final String tiqueteraId;
  final String nombre;
  final Unidad unidad;
  final int compradas;
  final int saldo;
  final EstadoTiquetera estado;
  final DateTime compradaEn;

  /// Último día en que sirve, en la fecha del negocio (AAAA-MM-DD).
  final String ultimoDia;
  final bool vigente;

  /// 1 = la que se gasta primero (la que vence antes, HU-05-03).
  final int? turno;
}

/// La suma de las tiqueteras vigentes de una unidad.
class SaldoPorUnidad {
  const SaldoPorUnidad({
    required this.unidad,
    required this.disponibles,
    required this.ultimoDia,
    required this.tiqueteras,
  });

  final Unidad unidad;
  final int disponibles;

  /// Último día de la que se gasta primero.
  final String ultimoDia;
  final int tiqueteras;
}

/// Un renglón de la historia del saldo; nada se borra (HU-05-05).
class Movimiento {
  const Movimiento({
    required this.eventoId,
    required this.tipo,
    required this.ocurridoEn,
    required this.unidades,
    this.tiquetera,
    this.motivo,
    this.nota,
    this.quien,
  });

  final String eventoId;

  /// SALE, CONSUMPTION, SALE_VOID, ADJUSTMENT, EXPIRATION…
  final String tipo;
  final DateTime ocurridoEn;
  final int unidades;
  final String? tiquetera;
  final String? motivo;
  final String? nota;
  final String? quien;
}

/// El saldo de un cliente en un negocio.
class EstadoDeCuenta {
  const EstadoDeCuenta({
    required this.saldos,
    required this.tiqueteras,
    this.movimientos = const [],
  });

  final List<SaldoPorUnidad> saldos;
  final List<Tiquetera> tiqueteras;
  final List<Movimiento> movimientos;
}

/// Lo que la persona ve en su app: su saldo en uno de sus negocios.
class SaldoEnNegocio {
  const SaldoEnNegocio({required this.comercioId, required this.comercio, required this.cuenta});

  final String comercioId;
  final String comercio;
  final EstadoDeCuenta cuenta;
}
