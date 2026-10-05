import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/database/app_database.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/clientes/data/datasources/clientes_local_datasource.dart';
import 'package:veci/features/clientes/data/datasources/clientes_remote_datasource.dart';
import 'package:veci/features/clientes/data/repositories/clientes_repository_impl.dart';
import 'package:veci/features/clientes/domain/entities/cliente_en_caja.dart';

import 'clientes_dobles.dart';

/// Servidor falso de la copia: responde 304 si la ETag coincide.
class _RemotoFalso implements ClientesRemoteDatasource {
  List<ClienteEnCaja> clientes = [clienteDePrueba()];
  String version = '1042.37';
  Fallo? fallo;
  final etagsRecibidas = <String?>[];

  @override
  Future<RespuestaCopia> bajarCopia({String? etag}) async {
    etagsRecibidas.add(etag);
    if (fallo != null) throw fallo!;
    if (etag == '"$version"') return RespuestaCopia(etag: etag);
    return RespuestaCopia(clientes: clientes, version: version, etag: '"$version"');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late _RemotoFalso remoto;
  late DateTime ahora;

  ClientesRepositoryImpl repositorio(String comercioId) =>
      ClientesRepositoryImpl(remoto, ClientesLocalDatasource(db), comercioId, reloj: () => ahora);

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    remoto = _RemotoFalso();
    ahora = DateTime(2026, 10, 5, 10, 42);
  });

  tearDown(() => db.close());

  test('la primera vez baja la copia completa y la guarda con su hora', () async {
    final copia = await repositorio('n1').actualizarCopia();

    expect(remoto.etagsRecibidas, [null]);
    expect(copia.clientes.single.nombre, 'Luz Marina Castro');
    expect(copia.alDiaEn, ahora);
    expect(copia.sinSenal, isFalse);
  });

  test('con 304 conserva la copia y solo cambia la hora', () async {
    await repositorio('n1').actualizarCopia();
    remoto.clientes = [];
    ahora = DateTime(2026, 10, 5, 11, 5);

    final copia = await repositorio('n1').actualizarCopia();

    expect(remoto.etagsRecibidas, [null, '"1042.37"']);
    expect(copia.clientes, hasLength(1));
    expect(copia.alDiaEn, ahora);
  });

  test('con 200 y otra versión reemplaza la copia', () async {
    await repositorio('n1').actualizarCopia();
    remoto
      ..version = '1043.01'
      ..clientes = [clienteDePrueba(id: 'c9', nombre: 'Ana Ruiz', busqueda: 'ana ruiz')];

    final copia = await repositorio('n1').actualizarCopia();

    expect(copia.clientes.single.nombre, 'Ana Ruiz');
    expect((await ClientesLocalDatasource(db).marca('n1'))?.etag, '"1043.01"');
  });

  test('sin señal sigue con la copia guardada y lo dice', () async {
    await repositorio('n1').actualizarCopia();
    remoto.fallo = const SinConexion();

    final copia = await repositorio('n1').actualizarCopia();

    expect(copia.sinSenal, isTrue);
    expect(copia.clientes, hasLength(1));
    expect(copia.alDiaEn, DateTime(2026, 10, 5, 10, 42));
  });

  test('cada negocio tiene su propia copia', () async {
    await repositorio('n1').actualizarCopia();

    final otra = await repositorio('n2').copiaGuardada();

    expect(otra.clientes, isEmpty);
    expect(otra.alDiaEn, isNull);
  });

  test('un rechazo del servidor no se oculta', () async {
    remoto.fallo = const PeticionRechazada(403, 'sin acceso');

    expect(repositorio('n1').actualizarCopia(), throwsA(isA<PeticionRechazada>()));
  });
}
