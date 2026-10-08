import 'package:drift/drift.dart';

/// Catálogo de venta de cada negocio (tipos activos y medios de pago) para vender sin
/// internet (HU-05-02). Se guarda tal como llega de GET /ventas/catalogo, en JSON.
@DataClassName('CatalogoDeVentaLocal')
class CatalogosDeVenta extends Table {
  TextColumn get comercioId => text()();
  TextColumn get contenido => text()();
  TextColumn get etag => text().nullable()();
  DateTimeColumn get alDiaEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {comercioId};
}

/// La cola de ventas de la caja (outbox, ADR-0004): cada venta se anota aquí antes de
/// enviarla y sale cuando el servidor la confirma. [rechazo] guarda por qué no la aceptó.
@DataClassName('VentaPendienteLocal')
class VentasPendientes extends Table {
  TextColumn get ventaId => text()();
  TextColumn get comercioId => text()();
  TextColumn get clienteId => text()();
  TextColumn get nombreCliente => text()();
  TextColumn get tipoId => text()();
  TextColumn get nombreTipo => text()();
  IntColumn get precio => integer()();
  TextColumn get medio => text()();
  TextColumn get canal => text().nullable()();
  TextColumn get referencia => text().nullable()();
  DateTimeColumn get ocurridaEn => dateTime()();
  IntColumn get intentos => integer().withDefault(const Constant(0))();
  TextColumn get rechazo => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {ventaId};
}
