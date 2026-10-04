import '../../../../core/error/fallo.dart';

/// Lo que se le dice a la persona cuando algo sale mal al entrar (guía de tono).
String mensajeDeFallo(Object error) => switch (error) {
  SinConexion() => 'No hay internet. Para entrar necesitas señal; luego la caja sigue sin ella.',
  PeticionRechazada(:final mensaje) => mensaje,
  _ => 'Algo nos falló. Intenta otra vez en un momento.',
};
