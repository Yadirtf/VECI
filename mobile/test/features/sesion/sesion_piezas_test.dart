import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/router/redireccion.dart';
import 'package:veci/core/router/rutas.dart';
import 'package:veci/features/sesion/data/datasources/almacen_sesion_seguro.dart';
import 'package:veci/features/sesion/data/datasources/dispositivo_local.dart';
import 'package:veci/features/sesion/domain/entities/estado_sesion.dart';

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

    test('sin negocio puede registrar el suyo; al tenerlo vuelve al inicio', () {
      final sinNegocio = SesionActiva(sesion: sesionDePrueba('t'), comercioId: null);
      final conNegocio = SesionActiva(sesion: sesionDePrueba('t'), comercioId: 'c1');
      expect(redirigir(sinNegocio, Rutas.registrarNegocio), isNull);
      expect(redirigir(conNegocio, Rutas.registrarNegocio), Rutas.inicio);
    });
  });
}
