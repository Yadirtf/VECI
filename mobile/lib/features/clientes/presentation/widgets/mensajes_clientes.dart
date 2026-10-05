import '../../../../core/error/fallo.dart';
import '../../domain/entities/lectura_qr.dart';

/// Textos de la caja de clientes según la guía de tono: qué pasó y qué hacer.
const pausaParaAfiliar =
    'Para afiliar necesitas internet. Búscalo de nuevo cuando vuelva la señal.';
const pausaParaRegistrar =
    'Para registrar necesitas internet. Búscalo de nuevo cuando vuelva la señal.';
const pausaParaLeerQr =
    'Para leer el QR necesitas internet. Mientras vuelve la señal, búscalo por su nombre.';
const _algoFallo = 'Algo nos falló. Intenta otra vez en un momento.';

/// El mensaje de cada QR que no lleva a una persona.
String? mensajeDeLectura(LecturaQr lectura) => switch (lectura) {
  QrCambiado() => 'Este QR ya no sirve: fue cambiado. Pídele que abra Mi QR en su app.',
  QrDeOtroNegocio() => 'Este QR es de otro negocio. Pídele su QR personal de VECI.',
  QrAjeno() => 'Este QR no es de VECI.',
  PorAfiliar() || YaEsCliente() => null,
};

String mensajeAlLeerQr(Object error) => _mensaje(error, pausaParaLeerQr);

String mensajeAlAfiliar(Object error) => _mensaje(error, pausaParaAfiliar);

String mensajeAlRegistrar(Object error) => _mensaje(error, pausaParaRegistrar);

/// Para la ficha y el PIN de bienvenida.
String mensajeConSenal(Object error) => _mensaje(
  error,
  'Sin internet no podemos traer su ficha. Intenta de nuevo cuando vuelva la señal.',
);

String _mensaje(Object error, String sinSenal) => switch (error) {
  SinConexion() => sinSenal,
  PeticionRechazada(codigo: 403) => 'No tienes acceso a este negocio. Habla con el dueño.',
  PeticionRechazada(:final mensaje) when mensaje.isNotEmpty => mensaje,
  _ => _algoFallo,
};
