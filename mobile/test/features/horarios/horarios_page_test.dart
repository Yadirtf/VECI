import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/di/core_providers.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/horarios/domain/entities/horario.dart';
import 'package:veci/features/horarios/domain/entities/horarios_semana.dart';
import 'package:veci/features/horarios/presentation/pages/horarios_page.dart';
import 'package:veci/features/horarios/presentation/providers/horarios_controller.dart';

Widget _pantalla(Future<HorariosSemana> Function() semana) => ProviderScope(
  overrides: [
    horariosSemanaProvider.overrideWith((ref) => semana()),
    // Lunes a mediodía.
    relojProvider.overrideWithValue(() => DateTime(2026, 10, 5, 12)),
  ],
  child: const MaterialApp(home: HorariosPage()),
);

const _lunes = DiaConHorarios(
  dia: 'MONDAY',
  nombre: 'Lunes',
  horarios: [
    Horario(
      id: 'h1',
      servicioNombre: 'Almuerzo',
      sedeId: 's1',
      dia: 'MONDAY',
      horaInicio: '11:30',
      horaFin: '15:00',
    ),
  ],
);

void main() {
  testWidgets('muestra los horarios del día con horas legibles', (tester) async {
    await tester.pumpWidget(
      _pantalla(() async => const HorariosSemana(dias: [_lunes], desdeCelular: false)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Lunes'), 200);

    expect(find.text('Lunes'), findsOneWidget);
    expect(find.text('11:30 a. m. – 3:00 p. m.'), findsOneWidget);
  });

  testWidgets('responde "¿ya es hora?" con lo que hay hoy', (tester) async {
    await tester.pumpWidget(
      _pantalla(() async => const HorariosSemana(dias: [_lunes], desdeCelular: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sí, es hora del almuerzo'), findsOneWidget);
    expect(find.textContaining('hasta las 3:00 p. m.'), findsOneWidget);
  });

  testWidgets('avisa cuando muestra lo guardado en el celular', (tester) async {
    await tester.pumpWidget(
      _pantalla(() async => const HorariosSemana(dias: [_lunes], desdeCelular: true)),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Estás sin internet'), findsOneWidget);
  });

  testWidgets('sin internet ni copia guardada invita a conectarse y reintentar', (tester) async {
    await tester.pumpWidget(_pantalla(() => Future.error(const SinConexion())));
    await tester.pumpAndSettle();

    expect(find.textContaining('No hay internet'), findsOneWidget);
    expect(find.text('Intentar de nuevo'), findsOneWidget);
  });
}
