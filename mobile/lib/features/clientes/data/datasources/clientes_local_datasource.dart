import 'package:drift/drift.dart' show Value;

import '../../../../core/database/app_database.dart';
import '../../domain/entities/cliente_en_caja.dart';
import '../models/cliente_model.dart';

/// Marca de la copia de clientes de un negocio: su versión, su ETag y cuándo se confirmó.
class MarcaDeCopia {
  const MarcaDeCopia({required this.version, required this.alDiaEn, this.etag});

  final String version;
  final String? etag;
  final DateTime alDiaEn;
}

/// La copia de clientes de cada negocio guardada en el celular (Drift).
class ClientesLocalDatasource {
  ClientesLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<ClienteEnCaja>> leer(String comercioId) async {
    final consulta = _db.select(_db.clientesEnCaja)..where((c) => c.comercioId.equals(comercioId));
    return (await consulta.get()).map(ClienteModel.desdeFila).toList();
  }

  Future<MarcaDeCopia?> marca(String comercioId) async {
    final consulta = _db.select(_db.copiasDeClientes)
      ..where((c) => c.comercioId.equals(comercioId));
    final fila = await consulta.getSingleOrNull();
    if (fila == null) return null;
    return MarcaDeCopia(version: fila.version, etag: fila.etag, alDiaEn: fila.alDiaEn);
  }

  /// Reemplaza la copia del negocio por la del servidor, en una sola transacción.
  Future<void> reemplazar(
    String comercioId,
    List<ClienteEnCaja> clientes, {
    required String version,
    required DateTime ahora,
    String? etag,
  }) => _db.transaction(() async {
    await (_db.delete(_db.clientesEnCaja)..where((c) => c.comercioId.equals(comercioId))).go();
    await _db.batch(
      (lote) => lote.insertAll(
        _db.clientesEnCaja,
        clientes.map((c) => ClienteModel.aFila(comercioId, c)),
      ),
    );
    await _db
        .into(_db.copiasDeClientes)
        .insertOnConflictUpdate(
          CopiasDeClientesCompanion.insert(
            comercioId: comercioId,
            version: version,
            etag: Value(etag),
            alDiaEn: ahora,
          ),
        );
  });

  /// El servidor dijo que nada cambió (304): solo se anota la hora.
  Future<void> confirmar(String comercioId, DateTime ahora) =>
      (_db.update(_db.copiasDeClientes)..where((c) => c.comercioId.equals(comercioId))).write(
        CopiasDeClientesCompanion(alDiaEn: Value(ahora)),
      );
}
