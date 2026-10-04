/// Hora actual inyectable, para que los casos de uso se prueben sin esperar.
abstract interface class Clock {
  DateTime now();
}
