import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/clientes_en_caja_table.dart';
import 'tables/horarios_locales_table.dart';
import 'tables/ventas_en_caja_table.dart';

part 'app_database.g.dart';

/// Base local del celular (Drift sobre SQLite): la app funciona sin internet (ADR-0004).
@DriftDatabase(
  tables: [
    HorariosLocales,
    MarcasSincronizacion,
    ClientesEnCaja,
    CopiasDeClientes,
    CatalogosDeVenta,
    VentasPendientes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Base en el almacenamiento de la app, abierta en un isolate aparte.
  factory AppDatabase.enElCelular() => AppDatabase(driftDatabase(name: 'veci'));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrador, desde, hasta) async {
      // v2 (EP-03): horarios en pausa y la ETag para no bajar lo que no cambió.
      if (desde < 2) {
        await migrador.addColumn(horariosLocales, horariosLocales.activo);
        await migrador.createTable(marcasSincronizacion);
      }
      // v3 (EP-04): copia de clientes para buscar en la caja sin internet.
      if (desde < 3) {
        await migrador.createTable(clientesEnCaja);
        await migrador.createTable(copiasDeClientes);
      }
      // v4 (EP-05): catálogo de venta y la cola de ventas hechas sin señal.
      if (desde < 4) {
        await migrador.createTable(catalogosDeVenta);
        await migrador.createTable(ventasPendientes);
      }
    },
    beforeOpen: (detalles) async {
      // WAL: escrituras rápidas sin bloquear lecturas (ADR-0011).
      await customStatement('PRAGMA journal_mode = WAL');
      await customStatement('PRAGMA synchronous = NORMAL');
    },
  );
}
