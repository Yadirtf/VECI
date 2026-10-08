import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/tiqueteras/domain/entities/catalogo.dart';
import 'package:veci/features/tiqueteras/domain/entities/estado_de_cuenta.dart';
import 'package:veci/features/tiqueteras/domain/entities/venta.dart';
import 'package:veci/features/tiqueteras/domain/repositories/ventas_repository.dart';

const almuerzo = Unidad(codigo: 'LUNCH', singular: 'almuerzo', plural: 'almuerzos');

const tipoDePrueba = TipoEnVenta(
  tipoId: 't1',
  nombre: '20 almuerzos',
  unidad: almuerzo,
  unidades: 20,
  precio: 220000,
  vigenciaDias: 30,
);

const efectivo = MedioDePago(codigo: 'CASH', nombre: 'Efectivo', necesitaCanal: false);
const transferencia = MedioDePago(
  codigo: 'BANK_TRANSFER',
  nombre: 'Transferencia',
  necesitaCanal: true,
  canales: [Canal(codigo: 'NEQUI', nombre: 'Nequi')],
);

const catalogoDePrueba = CatalogoDeVenta(tipos: [tipoDePrueba], medios: [efectivo, transferencia]);

Tiquetera tiqueteraDePrueba({int saldo = 14, bool vigente = true, int? turno = 1}) => Tiquetera(
  tiqueteraId: 'q1',
  nombre: '20 almuerzos',
  unidad: almuerzo,
  compradas: 20,
  saldo: saldo,
  estado: EstadoTiquetera.activa,
  compradaEn: DateTime(2026, 10, 8, 10),
  ultimoDia: '2026-11-06',
  vigente: vigente,
  turno: turno,
);

EstadoDeCuenta cuentaDePrueba({int saldo = 14}) => EstadoDeCuenta(
  saldos: [
    SaldoPorUnidad(unidad: almuerzo, disponibles: saldo, ultimoDia: '2026-11-06', tiqueteras: 1),
  ],
  tiqueteras: [tiqueteraDePrueba(saldo: saldo)],
  movimientos: [
    Movimiento(
      eventoId: 'e1',
      tipo: 'SALE',
      ocurridoEn: DateTime(2026, 10, 8, 10),
      unidades: 20,
      tiquetera: '20 almuerzos',
      quien: 'Ana Lucía',
    ),
    Movimiento(
      eventoId: 'e2',
      tipo: 'ADJUSTMENT',
      ocurridoEn: DateTime(2026, 10, 8, 11),
      unidades: -6,
      motivo: 'Cortesía',
      quien: 'Rosa',
    ),
  ],
);

/// Repositorio de ventas en memoria para las pantallas.
class VentasFalsas implements VentasRepository {
  CatalogoDeVenta? catalogo = catalogoDePrueba;
  Fallo? falloCatalogo;
  Object? falloVenta;
  Object? falloCuenta;
  bool sinSenal = false;
  final vendidas = <VentaEnCaja>[];
  List<VentaPorEnviar> cola = [];

  @override
  Future<CatalogoDeVenta?> catalogoGuardado() async => catalogo;

  @override
  Future<CatalogoDeVenta> actualizarCatalogo() async {
    if (falloCatalogo != null) throw falloCatalogo!;
    return catalogo!;
  }

  @override
  Future<EstadoDeCuenta> cuenta(String clienteId) async {
    if (falloCuenta != null) throw falloCuenta!;
    return cuentaDePrueba();
  }

  @override
  Future<ResultadoVenta> vender(VentaEnCaja venta) async {
    if (falloVenta != null) throw falloVenta!;
    vendidas.add(venta);
    return sinSenal ? const VentaGuardada() : VentaEnviada(cuentaDePrueba(saldo: 34));
  }

  @override
  Future<int> enviarPendientes() async => 0;

  @override
  Future<List<VentaPorEnviar>> porEnviar() async => cola;

  @override
  Future<void> descartar(String ventaId) async => cola.removeWhere((v) => v.ventaId == ventaId);
}

class MisTiqueterasFalsas implements MisTiqueterasRepository {
  List<SaldoEnNegocio>? copia;
  Fallo? fallo;
  List<SaldoEnNegocio> delServidor = [
    SaldoEnNegocio(comercioId: 'n1', comercio: 'Doña Rosa', cuenta: cuentaDePrueba()),
  ];

  @override
  Future<List<SaldoEnNegocio>?> guardadas() async => copia;

  @override
  Future<List<SaldoEnNegocio>> traer() async {
    if (fallo != null) throw fallo!;
    return delServidor;
  }

  @override
  Future<void> olvidar() async => copia = null;
}
