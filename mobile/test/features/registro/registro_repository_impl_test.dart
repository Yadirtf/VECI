import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/core/router/redireccion.dart';
import 'package:veci/core/router/rutas.dart';
import 'package:veci/features/registro/data/repositories/registro_repository_impl.dart';
import 'package:veci/features/registro/domain/entities/registro.dart';
import 'package:veci/features/sesion/data/repositories/sesion_repository_impl.dart';
import 'package:veci/features/sesion/domain/entities/estado_sesion.dart';
import 'package:veci/features/sesion/domain/usecases/gestor_sesion.dart';
import 'package:veci_api/api.dart';

import '../sesion/sesion_dobles.dart';

class _ApiFalsa extends RegistroDelClienteApi {
  RegistroRequest? pedido;
  ApiException? rechazo;

  @override
  Future<SesionResponse?> registrarme(
    RegistroRequest registroRequest, {
    Future<void>? abortTrigger,
  }) async {
    if (rechazo != null) throw rechazo!;
    pedido = registroRequest;
    return SesionResponse(
      segundosAcceso: 900,
      tokenAcceso: 'acceso',
      tokenRenovacion: 'renovacion',
      usuario: UsuarioResponse(id: 'u1', nombre: 'Luz Marina Chindoy'),
    );
  }
}

const _borrador = BorradorRegistro(
  celular: '+57 315 777 8888',
  nombres: ' Luz Marina ',
  numeroDocumento: '1.124.500.777',
  pin: '190573',
  pinRepetido: '190573',
);

Future<DispositivoRequest> _dispositivo() async => DispositivoRequest(
  id: 'd1',
  plataforma: DispositivoRequestPlataformaEnum.ANDROID,
  modelo: 'Moto',
  versionSo: 'Android 13',
  versionApp: 'local',
);

void main() {
  late _ApiFalsa api;
  late AlmacenFalso almacen;
  late GestorSesion gestor;
  late RegistroRepositoryImpl repositorio;

  setUp(() {
    api = _ApiFalsa();
    almacen = AlmacenFalso();
    gestor = GestorSesion(RepositorioFalso(), almacen, PendientesFalsos());
    repositorio = RegistroRepositoryImpl(
      api,
      _dispositivo,
      (r) => gestor.entrarConSesionNueva(sesionDesdeRespuesta(r, DateTime(2030))),
    );
  });

  test('envía los datos limpios y entra de una vez como cliente', () async {
    await repositorio.registrarme(_borrador, 'pol-1');

    expect(api.pedido?.celular, '3157778888');
    expect(api.pedido?.numeroDocumento, '1124500777');
    expect(api.pedido?.nombres, 'Luz Marina');
    expect(api.pedido?.apellidos, isNull);
    expect(api.pedido?.politicaVersionId, 'pol-1');
    expect(api.pedido?.dispositivo.id, 'd1');
    final estado = gestor.estado as SesionActiva;
    expect(estado.soloCliente, isTrue);
    expect(almacen.sesion?.tokenRenovacion, 'renovacion');
    expect(redirigir(estado, Rutas.registro), isNull);
    expect(redirigir(estado, Rutas.cargando), Rutas.miQr);
  });

  test('si ya tiene cuenta, devuelve el motivo para ofrecer entrar', () async {
    api.rechazo = ApiException(
      409,
      '{"codigo":"YA_TIENE_CUENTA","message":"Ese celular/documento ya está en VECI."}',
    );
    await expectLater(
      repositorio.registrarme(_borrador, 'pol-1'),
      throwsA(isA<PeticionRechazada>().having((f) => f.motivo, 'motivo', 'YA_TIENE_CUENTA')),
    );
    expect(gestor.estado, isA<SesionIniciando>());
  });
}
