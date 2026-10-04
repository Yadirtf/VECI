import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/horarios/domain/entities/horario.dart';
import 'package:veci/features/horarios/domain/repositories/horarios_repository.dart';
import 'package:veci/features/horarios/domain/usecases/obtener_horarios_semana.dart';

Horario horario(String dia, String inicio, [String servicio = 'Almuerzo']) => Horario(
  id: '$dia-$inicio',
  servicioNombre: servicio,
  sedeId: 'principal',
  dia: dia,
  horaInicio: inicio,
  horaFin: '23:00',
);

class _RepositorioFijo implements HorariosRepository {
  _RepositorioFijo(this.resultado);

  final ResultadoHorarios resultado;

  @override
  Future<ResultadoHorarios> obtener() async => resultado;
}

void main() {
  test('agrupa por día en orden de semana y de hora, sin días vacíos', () async {
    final caso = ObtenerHorariosSemana(
      _RepositorioFijo(
        ResultadoHorarios(
          horarios: [
            horario('TUESDAY', '11:30'),
            horario('MONDAY', '11:30'),
            horario('MONDAY', '06:30', 'Desayuno'),
          ],
          desdeCelular: true,
        ),
      ),
    );

    final semana = await caso.ejecutar();

    expect(semana.dias.map((d) => d.nombre), ['Lunes', 'Martes']);
    expect(semana.dias.first.horarios.map((h) => h.servicioNombre), ['Desayuno', 'Almuerzo']);
    expect(semana.desdeCelular, isTrue);
  });
}
