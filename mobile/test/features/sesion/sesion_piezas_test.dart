import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/router/redireccion.dart';
import 'package:veci/core/router/rutas.dart';
import 'package:veci/features/sesion/data/datasources/almacen_sesion_seguro.dart';
import 'package:veci/features/sesion/data/datasources/dispositivo_local.dart';
import 'package:veci/features/sesion/domain/entities/estado_sesion.dart';
import 'package:veci/features/sesion/domain/entities/sesion.dart';

import 'sesion_dobles.dart';

void main() {
  test('la sesión guardada vuelve igual', () {
    final original = sesionDePrueba('t1');
    final copia = sesionDesdeJson(sesionAJson(original));
    expect(copia.tokenRenovacion, 'r-t1');
    expect(copia.espacios.single.nombre, 'Restaurante La Vecina');
    expect(copia.venceEn, original.venceEn);
  });

  test('el id del celular es un UUID v4', () {
    final id = uuidV4(Random(1));
    expect(
      id,
      matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
    );
  });

  group('a dónde va la persona', () {
    test('sin sesión, a entrar; con PIN temporal, a crear el suyo', () {
      expect(redirigir(const SinSesion(), Rutas.inicio), Rutas.entrar);
      expect(redirigir(const SinSesion(), Rutas.entrar), isNull);
      expect(
        redirigir(const CambioDePin(tokenCambio: 't', nombre: 'Ana'), Rutas.entrar),
        Rutas.pinNuevo,
      );
    });

    test('sin negocio, a elegirlo; con negocio, sale de las pantallas de ingreso', () {
      final sinNegocio = SesionActiva(sesion: sesionDePrueba('t'), comercioId: null);
      final conNegocio = SesionActiva(sesion: sesionDePrueba('t'), comercioId: 'c1');
      expect(redirigir(sinNegocio, Rutas.inicio), Rutas.negocio);
      expect(redirigir(conNegocio, Rutas.entrar), Rutas.inicio);
      expect(redirigir(conNegocio, Rutas.horarios), isNull);
      expect(redirigir(const SesionIniciando(), Rutas.inicio), Rutas.cargando);
    });

    test('con o sin negocio, desde Ajustes pide el registro del suyo (ADR-0019)', () {
      final sinNegocio = SesionActiva(sesion: sesionDePrueba('t'), comercioId: null);
      final conNegocio = SesionActiva(sesion: sesionDePrueba('t'), comercioId: 'c1');
      for (final estado in [sinNegocio, conNegocio]) {
        expect(redirigir(estado, Rutas.ajustes), isNull);
        expect(redirigir(estado, Rutas.registrarNegocio), isNull);
      }
      expect(redirigir(const SinSesion(), Rutas.ajustes), Rutas.entrar);
    });

    test('sin sesión también puede crear su cuenta y leer la política (HU-04-01)', () {
      expect(redirigir(const SinSesion(), Rutas.registro), isNull);
      expect(redirigir(const SinSesion(), Rutas.politica), isNull);
      expect(redirigir(const SinSesion(), Rutas.miQr), Rutas.entrar);
    });

    test('quien solo es cliente tiene Mi QR o Tus negocios como inicio (EP-04)', () {
      final recienRegistrado = SesionActiva(
        sesion: sesionDePrueba('t', espacios: const []),
        comercioId: null,
      );
      final cliente = SesionActiva(
        sesion: sesionDePrueba('t', espacios: const [_clienteDeLaVecina]),
        comercioId: 'c1',
      );
      expect(recienRegistrado.soloCliente, isTrue);
      expect(redirigir(recienRegistrado, Rutas.cargando), Rutas.miQr);
      expect(redirigir(recienRegistrado, Rutas.negocio), Rutas.miQr);
      expect(redirigir(recienRegistrado, Rutas.registro), isNull);
      expect(redirigir(recienRegistrado, Rutas.registrarNegocio), isNull);
      expect(redirigir(cliente, Rutas.ajustes), isNull);
      expect(redirigir(cliente, Rutas.entrar), Rutas.tusNegocios);
      expect(redirigir(cliente, Rutas.inicio), Rutas.tusNegocios);
      expect(redirigir(cliente, '/caja'), Rutas.tusNegocios);
      expect(redirigir(cliente, Rutas.miQr), isNull);
      expect(redirigir(cliente, Rutas.qrDe('c1')), isNull);
    });

    test('el cajero sigue igual y también puede ver su QR', () {
      final cajero = SesionActiva(sesion: sesionDePrueba('t'), comercioId: 'c1');
      expect(cajero.soloCliente, isFalse);
      expect(redirigir(cajero, Rutas.miQr), isNull);
      expect(redirigir(cajero, Rutas.registro), Rutas.inicio);
      expect(Rutas.entrarCon('3157778888'), '/entrar?celular=3157778888');
    });
  });
}

const _clienteDeLaVecina = Espacio(
  comercioId: 'c1',
  nombre: 'Restaurante La Vecina',
  roles: ['CUSTOMER'],
  invitacionPendiente: false,
);
