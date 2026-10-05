import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/mi_qr/data/datasources/copia_mi_qr.dart';
import 'package:veci/features/mi_qr/data/repositories/mi_qr_repository_impl.dart';
import 'package:veci/features/mi_qr/domain/reglas/reglas_mi_qr.dart';
import 'package:veci/features/mi_qr/presentation/providers/mi_qr_providers.dart';

import 'mi_qr_dobles.dart';

void main() {
  late ApiMiQrFalsa api;
  late CajonEnMemoria cajon;
  late MiQrRepositoryImpl repositorio;

  setUp(() {
    api = ApiMiQrFalsa();
    cajon = CajonEnMemoria();
    repositorio = MiQrRepositoryImpl(api, CopiaMiQr(cajon));
  });

  test('trae el QR y guarda la copia para mostrarlo sin internet', () async {
    expect(await repositorio.qrGuardado(), isNull);
    final qr = await repositorio.traerQr();
    expect(qr.version, 1);
    expect((await repositorio.qrGuardado())?.token, 'VP1.qr1.firma');
  });

  test('al cambiar el QR, el guardado es el nuevo', () async {
    await repositorio.traerQr();
    final nuevo = await repositorio.regenerar();
    expect(nuevo.version, 2);
    expect((await repositorio.qrGuardado())?.token, 'VP1.qr2.firma');
  });

  test('sin señal no se puede cambiar el QR y el de antes sigue guardado', () async {
    await repositorio.traerQr();
    api.sinSenal = true;
    await expectLater(repositorio.regenerar(), throwsA(isA<SinConexion>()));
    expect((await repositorio.qrGuardado())?.version, 1);
  });

  test('guarda los negocios con su QR y los olvida al salir', () async {
    api.negocios = [negocioDePrueba(), negocioDePrueba(conQr: false)];
    await repositorio.traerNegocios();
    final guardados = await repositorio.negociosGuardados();
    expect(guardados?.first.qr?.token, 'V1.c1.firma');
    expect(guardados?.last.qr, isNull);
    expect(guardados?.first.afiliadoEn, DateTime(2026, 10, 3));

    await repositorio.olvidar();
    expect(await repositorio.negociosGuardados(), isNull);
    expect(cajon.datos, isEmpty);
  });

  test('una copia dañada se descarta', () async {
    cajon.datos['veci.mi-qr'] = '{no es json';
    expect(await repositorio.qrGuardado(), isNull);
    expect(cajon.datos, isEmpty);
  });

  group('lo guardado primero, luego lo del servidor', () {
    test('con señal muestra la copia y después lo nuevo', () async {
      await repositorio.traerQr();
      await repositorio.regenerar();
      api.version = 7;
      final vistas = await guardadoYAlDia(repositorio.qrGuardado, repositorio.traerQr).toList();
      expect(vistas.map((v) => v.valor.version), [2, 7]);
      expect(vistas.last.sinSenal, isFalse);
    });

    test('sin señal se queda con la copia y lo dice', () async {
      await repositorio.traerQr();
      api.sinSenal = true;
      final vistas = await guardadoYAlDia(repositorio.qrGuardado, repositorio.traerQr).toList();
      expect(vistas.last.valor.version, 1);
      expect(vistas.last.sinSenal, isTrue);
    });

    test('sin señal y sin copia, avisa el fallo', () {
      api.sinSenal = true;
      expect(
        guardadoYAlDia(repositorio.qrGuardado, repositorio.traerQr).toList(),
        throwsA(isA<SinConexion>()),
      );
    });
  });

  test('fechas y nombres como los diría un vecino', () {
    expect(fechaLegible(DateTime(2026, 10, 3), DateTime(2026, 12)), '3 de octubre');
    expect(fechaLegible(DateTime(2025, 1, 15), DateTime(2026, 12)), '15 de enero de 2025');
    expect(primerNombre('Luz Marina Chindoy'), 'Luz');
    expect(primerNombre(''), 'veci');
  });
}
