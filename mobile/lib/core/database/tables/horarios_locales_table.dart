import 'package:drift/drift.dart';

/// Copia local de los horarios de servicio para mostrarlos sin internet.
@DataClassName('HorarioLocal')
class HorariosLocales extends Table {
  TextColumn get id => text()();
  TextColumn get servicioNombre => text()();
  TextColumn get sedeId => text()();
  TextColumn get dia => text()();
  TextColumn get horaInicio => text()();
  TextColumn get horaFin => text()();
  BoolColumn get activo => boolean().withDefault(const Constant(true))();
  DateTimeColumn get guardadoEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Marca de la última sincronización de cada recurso (ETag del servidor): si nada
/// cambió, el servidor responde 304 y el celular no gasta datos (HU-03-02).
@DataClassName('MarcaSincronizacion')
class MarcasSincronizacion extends Table {
  TextColumn get recurso => text()();
  TextColumn get etag => text()();

  @override
  Set<Column<Object>> get primaryKey => {recurso};
}
