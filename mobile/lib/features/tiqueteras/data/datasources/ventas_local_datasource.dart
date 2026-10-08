import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/catalogo.dart';
import '../../domain/entities/venta.dart';

/// El catálogo guardado de un negocio: su JSON tal cual llegó, su ETag y cuándo se confirmó.
class CatalogoGuardado {
  const CatalogoGuardado({required this.contenido, required this.alDiaEn, this.etag});

  final Map<String, Object?> contenido;
  final String? etag;
  final DateTime alDiaEn;
}

/// El catálogo de venta y la cola de ventas del celular (Drift).
class VentasLocalDatasource {
  VentasLocalDatasource(this._db);

  final AppDatabase _db;

  Future<CatalogoGuardado?> catalogo(String comercioId) async {
    final consulta = _db.select(_db.catalogosDeVenta)
      ..where((c) => c.comercioId.equals(comercioId));
    final fila = await consulta.getSingleOrNull();
    if (fila == null) return null;
    final contenido = jsonDecode(fila.contenido);
    if (contenido is! Map<String, Object?>) return null;
    return CatalogoGuardado(contenido: contenido, etag: fila.etag, alDiaEn: fila.alDiaEn);
  }

  Future<void> guardarCatalogo(
    String comercioId,
    Map<String, Object?> contenido, {
    required DateTime ahora,
    String? etag,
  }) => _db
      .into(_db.catalogosDeVenta)
      .insertOnConflictUpdate(
        CatalogosDeVentaCompanion.insert(
          comercioId: comercioId,
          contenido: jsonEncode(contenido),
          etag: Value(etag),
          alDiaEn: ahora,
        ),
      );

  /// El servidor dijo que nada cambió (304): solo se anota la hora.
  Future<void> confirmarCatalogo(String comercioId, DateTime ahora) =>
      (_db.update(_db.catalogosDeVenta)..where((c) => c.comercioId.equals(comercioId))).write(
        CatalogosDeVentaCompanion(alDiaEn: Value(ahora)),
      );

  Future<void> encolar(String comercioId, VentaEnCaja v) => _db
      .into(_db.ventasPendientes)
      .insertOnConflictUpdate(
        VentasPendientesCompanion.insert(
          ventaId: v.ventaId,
          comercioId: comercioId,
          clienteId: v.clienteId,
          nombreCliente: v.nombreCliente,
          tipoId: v.tipo.tipoId,
          nombreTipo: v.tipo.nombre,
          precio: v.tipo.precio,
          medio: v.pago.medio,
          canal: Value(v.pago.canal),
          referencia: Value(v.pago.referencia),
          ocurridaEn: v.ocurridaEn,
        ),
      );

  /// Las que esperan señal (sin rechazo), de la más vieja a la más nueva.
  Future<List<VentaEnCaja>> enEspera(String comercioId) async {
    final consulta = _db.select(_db.ventasPendientes)
      ..where((v) => v.comercioId.equals(comercioId) & v.rechazo.isNull())
      ..orderBy([(v) => OrderingTerm.asc(v.ocurridaEn)]);
    return (await consulta.get()).map(_aVenta).toList();
  }

  Future<List<VentaPorEnviar>> todas(String comercioId) async {
    final consulta = _db.select(_db.ventasPendientes)
      ..where((v) => v.comercioId.equals(comercioId))
      ..orderBy([(v) => OrderingTerm.asc(v.ocurridaEn)]);
    return [
      for (final f in await consulta.get())
        VentaPorEnviar(
          ventaId: f.ventaId,
          nombreCliente: f.nombreCliente,
          nombreTipo: f.nombreTipo,
          precio: f.precio,
          ocurridaEn: f.ocurridaEn,
          rechazo: f.rechazo,
        ),
    ];
  }

  /// Ventas de cualquier negocio que aún no llegan al servidor (aviso al salir).
  Future<int> contarEnEspera() async {
    final cuantas = _db.ventasPendientes.ventaId.count();
    final consulta = _db.selectOnly(_db.ventasPendientes)
      ..addColumns([cuantas])
      ..where(_db.ventasPendientes.rechazo.isNull());
    return (await consulta.getSingle()).read(cuantas) ?? 0;
  }

  Future<void> quitar(String ventaId) =>
      (_db.delete(_db.ventasPendientes)..where((v) => v.ventaId.equals(ventaId))).go();

  Future<void> rechazar(String ventaId, String motivo) =>
      (_db.update(_db.ventasPendientes)..where((v) => v.ventaId.equals(ventaId))).write(
        VentasPendientesCompanion(rechazo: Value(motivo)),
      );

  Future<void> contarIntento(String ventaId) => _db.customUpdate(
    'UPDATE ventas_pendientes SET intentos = intentos + 1 WHERE venta_id = ?',
    variables: [Variable.withString(ventaId)],
    updates: {_db.ventasPendientes},
  );

  VentaEnCaja _aVenta(VentaPendienteLocal f) => VentaEnCaja(
    ventaId: f.ventaId,
    clienteId: f.clienteId,
    nombreCliente: f.nombreCliente,
    tipo: TipoEnVenta(
      tipoId: f.tipoId,
      nombre: f.nombreTipo,
      unidad: const Unidad(codigo: 'UNIT', singular: 'unidad', plural: 'unidades'),
      unidades: 0,
      precio: f.precio,
      vigenciaDias: 0,
    ),
    pago: Pago(medio: f.medio, canal: f.canal, referencia: f.referencia),
    ocurridaEn: f.ocurridaEn,
  );
}
