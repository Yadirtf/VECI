import 'package:veci_api/api.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/horario.dart';

/// Traducciones entre el API, la base local y la entidad del dominio.
abstract final class HorarioModel {
  static Horario desdeApi(HorarioResponse respuesta) => Horario(
    id: respuesta.id,
    servicioNombre: respuesta.servicioNombre ?? 'Servicio',
    sedeId: respuesta.sedeId,
    dia: respuesta.dia,
    horaInicio: respuesta.horaInicio,
    horaFin: respuesta.horaFin,
  );

  static Horario desdeFila(HorarioLocal fila) => Horario(
    id: fila.id,
    servicioNombre: fila.servicioNombre,
    sedeId: fila.sedeId,
    dia: fila.dia,
    horaInicio: fila.horaInicio,
    horaFin: fila.horaFin,
  );

  static HorariosLocalesCompanion aFila(Horario horario, DateTime guardadoEn) =>
      HorariosLocalesCompanion.insert(
        id: horario.id,
        servicioNombre: horario.servicioNombre,
        sedeId: horario.sedeId,
        dia: horario.dia,
        horaInicio: horario.horaInicio,
        horaFin: horario.horaFin,
        guardadoEn: guardadoEn,
      );
}
