import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/sesion/domain/entities/estado_sesion.dart';
import 'package:veci/features/sesion/domain/entities/sesion.dart';
import 'package:veci/features/sesion/domain/usecases/gestor_sesion.dart';

import 'sesion_dobles.dart';

void main() {
  late RepositorioFalso repositorio;
  late AlmacenFalso almacen;
  GestorSesion gestor({int pendientes = 0, DateTime? ahora}) => GestorSesion(
    repositorio,
    almacen,
    PendientesFalsos(pendientes),
    ahora: ahora == null ? null : () => ahora,
  );

  setUp(() {
    repositorio = RepositorioFalso();
    almacen = AlmacenFalso();
  });

  test('sin sesión guardada pide entrar', () async {
    final g = gestor();
    await g.iniciar();
    expect(g.estado, isA<SinSesion>());
  });

  test('entra con PIN, guarda la sesión y elige su único negocio', () async {
    final g = gestor();
    await g.entrarConPin('3100000102', '246813');
    expect((g.estado as SesionActiva).comercioId, 'c1');
    expect(almacen.sesion?.tokenRenovacion, 'r-t1');
  });

  test('con PIN temporal pide crear el propio (HU-02-05)', () async {
    repositorio.ingreso = const IngresoConCambioDePin(tokenCambio: 'tc', nombre: 'Ana');
    final g = gestor();
    await g.entrarConPin('3124567890', '482915');
    expect(g.estado, isA<CambioDePin>());
    await g.crearPinNuevo('730284');
    expect((g.estado as SesionActiva).sesion.tokenAcceso, 't-nuevo');
  });

  test('sin internet al abrir, la caja sigue con la sesión guardada (HU-02-06)', () async {
    almacen.sesion = sesionDePrueba('viejo', venceEn: DateTime(2020));
    repositorio.sinSenal = true;
    final g = gestor();
    await g.iniciar();
    expect((g.estado as SesionActiva).comercioId, 'c1');
    expect(almacen.sesion, isNotNull);
  });

  test('renueva una sola vez aunque varias peticiones lo pidan', () async {
    almacen.sesion = sesionDePrueba('viejo', venceEn: DateTime(2020));
    repositorio.sinSenal = true;
    final g = gestor(ahora: DateTime(2026));
    await g.iniciar();
    repositorio
      ..sinSenal = false
      ..renovaciones = 0;
    final tokens = await Future.wait([g.tokenVigente(), g.tokenVigente()]);
    expect(tokens, ['t2', 't2']);
    expect(repositorio.renovaciones, 1);
  });

  test('si cerraron la sesión desde el panel, avisa los registros sin enviar', () async {
    almacen.sesion = sesionDePrueba('viejo');
    repositorio.renovada = null;
    final g = gestor(pendientes: 3);
    await g.iniciar();
    final estado = g.estado as SinSesion;
    expect(estado.aviso, contains('3 registros guardados'));
    expect(almacen.sesion, isNull);
  });

  test('un fallo de red al renovar no cierra la sesión', () async {
    final g = gestor(ahora: DateTime(2031));
    await g.entrarConPin('3100000102', '246813');
    repositorio.sinSenal = true;
    await expectLater(g.tokenVigente(), throwsA(isA<SinConexion>()));
    expect(g.estado, isA<SesionActiva>());
  });

  test('elegir y cambiar de negocio', () async {
    repositorio.ingreso = IngresoConSesion(
      sesionDePrueba(
        't1',
        espacios: const [
          negocio,
          Espacio(
            comercioId: 'c2',
            nombre: 'El Trigal',
            roles: ['CUSTOMER'],
            invitacionPendiente: false,
          ),
        ],
      ),
    );
    final g = gestor();
    await g.entrarConPin('3100000102', '246813');
    expect((g.estado as SesionActiva).comercioId, isNull);
    await g.elegirComercio('c2');
    expect(repositorio.elegidos, ['c2']);
    expect((g.estado as SesionActiva).negocio?.nombre, 'El Trigal');
    await g.cambiarDeNegocio();
    expect((g.estado as SesionActiva).comercioId, isNull);
  });

  test('salir avisa al servidor y olvida todo', () async {
    final g = gestor();
    final cambios = <EstadoSesion>[];
    g.cambios.listen(cambios.add);
    await g.entrarConPin('3100000102', '246813');
    await g.salir();
    expect(repositorio.salidas, ['t1']);
    expect(g.estado, isA<SinSesion>());
    expect(almacen.sesion, isNull);
    await Future<void>.delayed(Duration.zero);
    expect(cambios.length, 2);
  });
}
