import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/database/app_database.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/core/observabilidad/vigilante_sincronizacion.dart';
import 'package:veci/features/horarios/data/datasources/horarios_local_datasource.dart';
import 'package:veci/features/horarios/data/datasources/horarios_remote_datasource.dart';
import 'package:veci/features/horarios/data/repositories/horarios_repository_impl.dart';
import 'package:veci/features/horarios/domain/entities/horario.dart';

class _RemotoFalso implements HorariosRemoteDatasource {
  List<Horario> horarios = [];
  Fallo? fallo;

  @override
  Future<List<Horario>> listar() async {
    if (fallo != null) throw fallo!;
    return horarios;
  }
}

const _almuerzo = Horario(
  id: 'h1',
  servicioNombre: 'Almuerzo',
  sedeId: 's1',
  dia: 'MONDAY',
  horaInicio: '11:30',
  horaFin: '15:00',
);

void main() {
  late AppDatabase db;
  late _RemotoFalso remoto;
  late HorariosRepositoryImpl repositorio;
  late List<int> alertas;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remoto = _RemotoFalso();
    alertas = [];
    final vigilante = VigilanteSincronizacion(alertar: (fallos, _) => alertas.add(fallos));
    repositorio = HorariosRepositoryImpl(remoto, HorariosLocalDatasource(db), vigilante: vigilante);
  });

  tearDown(() => db.close());

  test('con internet trae del API y guarda una copia en el celular', () async {
    remoto.horarios = [_almuerzo];

    final resultado = await repositorio.obtener();

    expect(resultado.desdeCelular, isFalse);
    expect(await HorariosLocalDatasource(db).leer(), hasLength(1));
  });

  test('sin internet devuelve lo último guardado', () async {
    remoto.horarios = [_almuerzo];
    await repositorio.obtener();
    remoto.fallo = const SinConexion();

    final resultado = await repositorio.obtener();

    expect(resultado.desdeCelular, isTrue);
    expect(resultado.horarios.single.servicioNombre, 'Almuerzo');
  });

  test('sin internet y sin copia guardada informa el fallo', () async {
    remoto.fallo = const SinConexion();

    expect(repositorio.obtener(), throwsA(isA<SinConexion>()));
  });

  test('un rechazo del servidor (403) no se oculta con la copia local', () async {
    remoto.horarios = [_almuerzo];
    await repositorio.obtener();
    remoto.fallo = const PeticionRechazada(403, 'sin acceso');

    expect(repositorio.obtener(), throwsA(isA<PeticionRechazada>()));
  });

  test('tres caídas seguidas del servidor alertan; quedarse sin señal no', () async {
    remoto.horarios = [_almuerzo];
    await repositorio.obtener();

    remoto.fallo = const SinConexion();
    for (var i = 0; i < 3; i++) {
      await repositorio.obtener();
    }
    expect(alertas, isEmpty);

    remoto.fallo = const ServidorNoDisponible(503);
    for (var i = 0; i < 3; i++) {
      await repositorio.obtener();
    }
    expect(alertas, [3]);
  });
}
