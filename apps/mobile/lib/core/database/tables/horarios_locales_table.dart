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
  DateTimeColumn get guardadoEn => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
