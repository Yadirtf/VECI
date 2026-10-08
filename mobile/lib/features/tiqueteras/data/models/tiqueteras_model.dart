import 'package:veci_api/api.dart';

import '../../domain/entities/catalogo.dart';
import '../../domain/entities/estado_de_cuenta.dart';

/// Traduce lo que manda la API (y lo guardado en el celular, en JSON) a las entidades.
abstract final class TiqueterasModel {
  static Unidad unidad(UnidadResponse u) =>
      Unidad(codigo: u.codigo, singular: u.singular, plural: u.plural);

  static TipoEnVenta tipo(TipoResponse t) => TipoEnVenta(
    tipoId: t.tipoId,
    nombre: t.nombre,
    unidad: unidad(t.unidad),
    unidades: t.unidades.toInt(),
    precio: t.precio.toInt(),
    vigenciaDias: t.vigenciaDias.toInt(),
  );

  static MedioDePago medio(MedioDePagoResponse m) => MedioDePago(
    codigo: m.codigo,
    nombre: m.nombre,
    necesitaCanal: m.necesitaCanal,
    canales: [for (final c in m.canales) Canal(codigo: c.codigo, nombre: c.nombre)],
  );

  static CatalogoDeVenta catalogo(CatalogoDeVentaResponse c, {DateTime? alDiaEn}) =>
      CatalogoDeVenta(
        tipos: c.tipos.map(tipo).toList(),
        medios: c.medios.map(medio).toList(),
        alDiaEn: alDiaEn,
      );

  static Tiquetera tiquetera(TiqueteraResponse t) => Tiquetera(
    tiqueteraId: t.tiqueteraId,
    nombre: t.nombre,
    unidad: unidad(t.unidad),
    compradas: t.compradas.toInt(),
    saldo: t.saldo.toInt(),
    estado: EstadoTiquetera.desde(t.estado.toJson()),
    compradaEn: t.compradaEn,
    ultimoDia: t.ultimoDia,
    vigente: t.vigente,
    turno: t.turno?.toInt(),
  );

  static SaldoPorUnidad saldo(SaldoResponse s) => SaldoPorUnidad(
    unidad: unidad(s.unidad),
    disponibles: s.disponibles.toInt(),
    ultimoDia: s.ultimoDia,
    tiqueteras: s.tiqueteras.toInt(),
  );

  static Movimiento movimiento(MovimientoResponse m) => Movimiento(
    eventoId: m.eventoId,
    tipo: m.tipo.toJson(),
    ocurridoEn: m.ocurridoEn,
    unidades: m.unidades.toInt(),
    tiquetera: m.tiquetera,
    motivo: m.motivo,
    nota: m.nota,
    quien: m.quien,
  );

  static EstadoDeCuenta cuenta(EstadoDeCuentaResponse c) => EstadoDeCuenta(
    saldos: c.saldos.map(saldo).toList(),
    tiqueteras: c.tiqueteras.map(tiquetera).toList(),
    movimientos: c.movimientos.map(movimiento).toList(),
  );

  static EstadoDeCuenta deLaVenta(VentaResponse v) => EstadoDeCuenta(
    saldos: v.saldos.map(saldo).toList(),
    tiqueteras: v.tiqueteras.map(tiquetera).toList(),
  );

  static SaldoEnNegocio enNegocio(MisTiqueterasResponse m) => SaldoEnNegocio(
    comercioId: m.comercioId,
    comercio: m.comercio,
    cuenta: EstadoDeCuenta(
      saldos: m.saldos.map(saldo).toList(),
      tiqueteras: m.tiqueteras.map(tiquetera).toList(),
    ),
  );
}
