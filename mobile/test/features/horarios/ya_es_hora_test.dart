import 'package:flutter_test/flutter_test.dart';
import 'package:veci/features/horarios/domain/entities/horario.dart';
import 'package:veci/features/horarios/domain/reglas/ya_es_hora.dart';
import 'package:veci/features/horarios/presentation/widgets/frase_del_momento.dart';

Horario _h(String nombre, String inicio, String fin, {String dia = 'MONDAY', bool activo = true}) =>
    Horario(
      id: '$nombre$dia',
      servicioNombre: nombre,
      sedeId: 's1',
      dia: dia,
      horaInicio: inicio,
      horaFin: fin,
      activo: activo,
    );

// 5 de octubre de 2026 es lunes.
DateTime _lunes(int hora, int minuto) => DateTime(2026, 10, 5, hora, minuto);

final _dia = [
  _h('Almuerzo', '11:30', '15:00'),
  _h('Desayuno', '06:30', '09:30'),
  _h('Cena', '18:00', '21:00', activo: false),
  _h('Almuerzo', '11:00', '14:00', dia: 'TUESDAY'),
];

void main() {
  test('en pleno almuerzo dice que sí y cuánto falta para cerrar', () {
    final momento = momentoDelServicio(_dia, _lunes(14, 20));
    expect(momento, isA<EnServicio>());
    expect(fraseDelMomento(momento), (
      'Sí, es hora del almuerzo',
      'Atiendes hasta las 3:00 p. m. (en 40 minutos).',
    ));
  });

  test('entre servicios dice cuánto falta para el siguiente', () {
    final momento = momentoDelServicio(_dia, _lunes(10, 15));
    expect((momento as AntesDeServicio).horario.servicioNombre, 'Almuerzo');
    expect(
      fraseDelMomento(momento).$2,
      'Almuerzo empieza a las 11:30 a. m., en 1 hora y 15 minutos.',
    );
  });

  test('un servicio en pausa no cuenta: después del almuerzo ya se cerró', () {
    expect(momentoDelServicio(_dia, _lunes(18, 30)), isA<CerradoPorHoy>());
  });

  test('un día sin servicios es de descanso', () {
    expect(momentoDelServicio(_dia, DateTime(2026, 10, 11, 12)), isA<DiaDeDescanso>());
  });

  test('las onces van con artículo femenino plural', () {
    final momento = momentoDelServicio([_h('Onces', '15:00', '17:00')], _lunes(16, 0));
    expect(fraseDelMomento(momento).$1, 'Sí, es hora de las onces');
  });
}
