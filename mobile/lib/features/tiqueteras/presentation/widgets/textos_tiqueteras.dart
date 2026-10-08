import '../../../../core/error/fallo.dart';
import '../../domain/entities/estado_de_cuenta.dart';

/// Textos de tiqueteras según la guía de tono: qué pasó y qué hacer.
const sinSenalParaSaldo =
    'Sin internet no podemos traer su saldo. Igual puedes venderle: la venta se guarda '
    'y se envía sola cuando vuelva la señal.';
const ventaGuardada =
    'Sin señal: la venta quedó guardada en este celular. Se envía sola cuando vuelva '
    'internet; no la cobres otra vez.';
const _algoFallo = 'Algo nos falló. Intenta otra vez en un momento.';

String mensajeDeVenta(Object error) => switch (error) {
  SinConexion() => 'Para bajar las tiqueteras la primera vez necesitas internet.',
  PeticionRechazada(codigo: 403) => 'No tienes permiso para vender en este negocio.',
  PeticionRechazada(:final mensaje) when mensaje.isNotEmpty => mensaje,
  _ => _algoFallo,
};

String mensajeDeSaldo(Object error) => switch (error) {
  SinConexion() => sinSenalParaSaldo,
  PeticionRechazada(:final mensaje) when mensaje.isNotEmpty => mensaje,
  _ => _algoFallo,
};

const textoEstado = {
  EstadoTiquetera.activa: 'Vigente',
  EstadoTiquetera.agotada: 'Agotada',
  EstadoTiquetera.vencida: 'Vencida',
  EstadoTiquetera.anulada: 'Anulada',
};

/// "14 de 20 · último día 6 nov" o "Vencida · era hasta el 6 nov".
String detalleDeTiquetera(Tiquetera t, String dia) {
  if (t.vigente) return '${t.saldo} de ${t.compradas} · último día $dia';
  if (t.estado == EstadoTiquetera.activa) return 'Vencida · era hasta el $dia';
  return '${textoEstado[t.estado]} · ${t.saldo} de ${t.compradas}';
}
