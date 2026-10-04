import '../../domain/repositories/sesion_repository.dart';

/// Mientras no exista la cola de envío (outbox, EP-07), no hay registros pendientes.
/// EP-07 reemplaza esta pieza en core/di por la que cuenta la cola real.
class EventosPendientesSinOutbox implements EventosPendientes {
  const EventosPendientesSinOutbox();

  @override
  Future<int> contar() async => 0;
}
