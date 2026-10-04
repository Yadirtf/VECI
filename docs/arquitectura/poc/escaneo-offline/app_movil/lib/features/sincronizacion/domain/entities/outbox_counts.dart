/// Estado de la bandeja de salida por código.
class OutboxCounts {
  const OutboxCounts({this.pending = 0, this.applied = 0, this.rejected = 0});

  final int pending;
  final int applied;
  final int rejected;

  int get total => pending + applied + rejected;
}
