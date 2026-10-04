import '../../../../core/sync/outbox_dao.dart';
import '../../domain/entities/consumption_event.dart';
import '../../domain/repositories/consumption_outbox.dart';
import '../models/consumption_event_model.dart';

class ConsumptionOutboxImpl implements ConsumptionOutbox {
  const ConsumptionOutboxImpl(this._outbox);

  final OutboxDao _outbox;

  @override
  Future<void> register(ConsumptionEvent event) => _outbox.enqueue(event.toOutboxRow());

  @override
  Future<void> registerAll(List<ConsumptionEvent> events) =>
      _outbox.enqueueAll([for (final e in events) e.toOutboxRow()]);
}
