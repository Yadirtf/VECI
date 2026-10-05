import '../../../../core/database/app_database.dart';
import '../../domain/entities/horario.dart';
import '../models/horario_model.dart';

/// Horarios guardados en el celular para mostrarlos sin internet.
class HorariosLocalDatasource {
  HorariosLocalDatasource(this._db);

  final AppDatabase _db;

  Future<List<Horario>> leer() async {
    final filas = await _db.select(_db.horariosLocales).get();
    return filas.map(HorarioModel.desdeFila).toList();
  }

  static const _recurso = 'horarios';

  /// ETag de la última copia; null si nunca se guardó.
  Future<String?> etag() async {
    final consulta = _db.select(_db.marcasSincronizacion)..where((m) => m.recurso.equals(_recurso));
    return (await consulta.getSingleOrNull())?.etag;
  }

  /// Reemplaza la copia local por la del servidor (y su ETag) en una sola transacción.
  Future<void> reemplazar(List<Horario> horarios, DateTime ahora, {String? etag}) {
    return _db.transaction(() async {
      await _db.delete(_db.horariosLocales).go();
      await (_db.delete(_db.marcasSincronizacion)..where((m) => m.recurso.equals(_recurso))).go();
      if (etag != null) {
        await _db
            .into(_db.marcasSincronizacion)
            .insert(MarcasSincronizacionCompanion.insert(recurso: _recurso, etag: etag));
      }
      await _db.batch(
        (lote) =>
            lote.insertAll(_db.horariosLocales, horarios.map((h) => HorarioModel.aFila(h, ahora))),
      );
    });
  }
}
