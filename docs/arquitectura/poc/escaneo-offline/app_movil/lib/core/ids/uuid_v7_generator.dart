import 'package:uuid/uuid.dart';

import '../domain/id_generator.dart';

class UuidV7Generator implements IdGenerator {
  static const _uuid = Uuid();

  @override
  String next() => _uuid.v7();
}
