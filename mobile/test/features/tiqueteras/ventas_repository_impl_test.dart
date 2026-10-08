import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/database/app_database.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/tiqueteras/data/datasources/ventas_local_datasource.dart';
import 'package:veci/features/tiqueteras/data/datasources/ventas_remote_datasource.dart';
import 'package:veci/features/tiqueteras/data/repositories/ventas_repository_impl.dart';
import 'package:veci/features/tiqueteras/domain/entities/venta.dart';
import 'package:veci_api/api.dart';

import 'tiqueteras_dobles.dart';

const _unidad = {'codigo': 'LUNCH', 'singular': 'almuerzo', 'plural': 'almuerzos'};

final _catalogo = <String, Object?>{
  'version': '3.1',
  'tipos': [
    {
      'tipoId': 't1',
      'nombre': '20 almuerzos',
      'unidad': _unidad,
      'unidades': 20,
      'precio': 220000,
      'precioPorUnidad': 11000,
      'vigenciaDias': 30,
      'estado': 'ACTIVE',
      'vendidas': 0,
      'vigentes': 0,
    },
  ],
  'medios': [
    {'codigo': 'CASH', 'nombre': 'Efectivo', 'necesitaCanal': false, 'canales': <Object>[]},
  ],
};

final _saldo = {
  'saldos': [
    {
      'unidad': _unidad,
      'disponibles': 20,
      'proximoVencimiento': '2026-11-07T05:00:00Z',
      'ultimoDia': '2026-11-06',
      'tiqueteras': 1,
    },
  ],
  'tiqueteras': [
    {
      'tiqueteraId': 'q1',
      'clienteId': 'c1',
      'ventaId': 'v1',
      'tipoId': 't1',
      'nombre': '20 almuerzos',
      'unidad': _unidad,
      'compradas': 20,
      'saldo': 20,
      'estado': 'ACTIVE',
      'compradaEn': '2026-10-08T15:00:00Z',
      'venceEn': '2026-11-07T05:00:00Z',
      'ultimoDia': '2026-11-06',
      'vigente': true,
      'turno': 1,
    },
  ],
};

/// Servidor falso: catálogo con ETag y ventas que se pueden cortar o rechazar.
class _RemotoFalso implements VentasRemoteDatasource {
  Fallo? fallo;
  final etags = <String?>[];
  final enviadas = <(String, bool)>[];

  @override
  Future<RespuestaCatalogo> bajarCatalogo({String? etag}) async {
    etags.add(etag);
    if (fallo != null) throw fallo!;
    if (etag == '"3.1"') return RespuestaCatalogo(etag: etag);
    return RespuestaCatalogo(contenido: _catalogo, etag: '"3.1"');
  }

  @override
  Future<VentaResponse> vender(VentaEnCaja v, {required bool sinConexion}) async {
    if (fallo != null) throw fallo!;
    enviadas.add((v.ventaId, sinConexion));
    final tiquetera = (_saldo['tiqueteras']! as List).first as Map<String, Object?>;
    return VentaResponse.fromJson({
      ..._saldo,
      'ventaId': v.ventaId,
      'clienteId': v.clienteId,
      'repetida': false,
      'origen': sinConexion ? 'OFFLINE_SYNC' : 'ONLINE',
      'tiquetera': tiquetera,
    })!;
  }

  @override
  Future<EstadoDeCuentaResponse> cuenta(String clienteId) async => EstadoDeCuentaResponse.fromJson({
    ..._saldo,
    'clienteId': clienteId,
    'movimientos': <Object>[],
  })!;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

VentaEnCaja _venta(String id, {DateTime? en}) => VentaEnCaja(
  ventaId: id,
  clienteId: 'c1',
  nombreCliente: 'Luz Marina',
  tipo: tipoDePrueba,
  pago: const Pago(medio: 'BANK_TRANSFER', canal: 'NEQUI', referencia: 'M1'),
  ocurridaEn: en ?? DateTime(2026, 10, 8, 12),
);

void main() {
  late AppDatabase db;
  late _RemotoFalso remoto;
  late VentasLocalDatasource local;
  late VentasRepositoryImpl repo;
  final ahora = DateTime(2026, 10, 8, 12, 30);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remoto = _RemotoFalso();
    local = VentasLocalDatasource(db);
    repo = VentasRepositoryImpl(remoto, local, 'n1', reloj: () => ahora);
  });

  tearDown(() => db.close());

  test('guarda el catálogo con su ETag y sin señal vende con lo guardado', () async {
    expect(await repo.catalogoGuardado(), isNull);
    final primero = await repo.actualizarCatalogo();
    expect(primero.tipos.single.precio, 220000);
    expect(primero.medios.single.codigo, 'CASH');
    await repo.actualizarCatalogo();
    expect(remoto.etags, [null, '"3.1"']);
    remoto.fallo = const SinConexion();
    final sinSenal = await repo.actualizarCatalogo();
    expect((sinSenal.sinSenal, sinSenal.alDiaEn), (true, ahora));
  });

  test('sin catálogo guardado y sin señal, lo dice', () async {
    remoto.fallo = const SinConexion();
    expect(repo.actualizarCatalogo(), throwsA(isA<SinConexion>()));
  });

  test('con señal la venta llega al instante y no queda en la cola', () async {
    final resultado = await repo.vender(_venta('v1'));
    expect(resultado, isA<VentaEnviada>());
    expect((resultado as VentaEnviada).cuenta.saldos.single.disponibles, 20);
    expect(remoto.enviadas, [('v1', false)]);
    expect(await local.contarEnEspera(), 0);
    expect((await repo.cuenta('c1')).tiqueteras.single.turno, 1);
  });

  test('sin señal queda en la cola y se envía después con su hora', () async {
    remoto.fallo = const SinConexion();
    expect(await repo.vender(_venta('v1')), isA<VentaGuardada>());
    remoto.fallo = const ServidorNoDisponible(503);
    expect(await repo.vender(_venta('v2', en: DateTime(2026, 10, 8, 12, 5))), isA<VentaGuardada>());
    expect(await local.contarEnEspera(), 2);
    expect(await repo.enviarPendientes(), 0);
    remoto.fallo = null;
    expect(await repo.enviarPendientes(), 2);
    expect(remoto.enviadas, [('v1', true), ('v2', true)]);
    expect(await repo.porEnviar(), isEmpty);
  });

  test('si el servidor rechaza, en línea se avisa y en la cola queda con su motivo', () async {
    remoto.fallo = const PeticionRechazada(409, 'El precio cambió.', motivo: 'PRECIO_CAMBIO');
    expect(repo.vender(_venta('v1')), throwsA(isA<PeticionRechazada>()));
    await Future<void>.delayed(Duration.zero);
    expect(await repo.porEnviar(), isEmpty);
    remoto.fallo = const SinConexion();
    await repo.vender(_venta('v2'));
    remoto.fallo = const PeticionRechazada(404, 'Ya no es cliente.');
    await repo.enviarPendientes();
    final cola = await repo.porEnviar();
    expect((cola.single.ventaId, cola.single.rechazo), ('v2', 'Ya no es cliente.'));
    expect(await local.contarEnEspera(), 0);
    await repo.descartar('v2');
    expect(await repo.porEnviar(), isEmpty);
  });
}
