/// Genera ids únicos sin coordinación con el servidor (UUID v7, ADR-0004).
abstract interface class IdGenerator {
  String next();
}
