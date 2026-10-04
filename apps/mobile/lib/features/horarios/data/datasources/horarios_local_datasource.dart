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

  /// Reemplaza la copia local por la del servidor en una sola transacción.
  Future<void> reemplazar(List<Horario> horarios, DateTime ahora) {
    return _db.transaction(() async {
      await _db.delete(_db.horariosLocales).go();
      await _db.batch(
        (lote) =>
            lote.insertAll(_db.horariosLocales, horarios.map((h) => HorarioModel.aFila(h, ahora))),
      );
    });
  }
}
