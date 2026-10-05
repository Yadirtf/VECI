import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/clientes_providers.dart';
import '../../domain/entities/ficha_cliente.dart';
import '../../domain/entities/lectura_qr.dart';
import '../widgets/mensajes_clientes.dart';
import 'copia_clientes_controller.dart';

/// En qué va la lectura de un QR en la caja.
sealed class PasoLectura {
  const PasoLectura();
}

/// La cámara está buscando un QR.
final class Mirando extends PasoLectura {
  const Mirando();
}

/// Se leyó un QR y se pregunta al servidor de quién es.
final class Consultando extends PasoLectura {
  const Consultando();
}

/// El servidor respondió. Con [PorAfiliar] se espera la confirmación del cajero.
final class Leido extends PasoLectura {
  const Leido(this.lectura, this.token);

  final LecturaQr lectura;
  final String token;
}

/// Se está afiliando a la persona confirmada.
final class Afiliando extends PasoLectura {
  const Afiliando(this.lectura);

  final PorAfiliar lectura;
}

/// Ya es cliente (recién afiliado o de antes): la pantalla abre su ficha.
final class ListoParaFicha extends PasoLectura {
  const ListoParaFicha(this.ficha, {required this.recienAfiliado});

  final FichaCliente ficha;
  final bool recienAfiliado;
}

/// Algo no salió: el mensaje dice qué hacer.
final class LecturaFallida extends PasoLectura {
  const LecturaFallida(this.mensaje);

  final String mensaje;
}

/// Leer el QR del cliente y afiliarlo (HU-04-02). Necesita señal en EP-04.
final lecturaQrProvider = NotifierProvider.autoDispose<LecturaQrController, PasoLectura>(
  LecturaQrController.new,
);

class LecturaQrController extends Notifier<PasoLectura> {
  @override
  PasoLectura build() => const Mirando();

  /// Un QR a la vez: mientras se consulta o se muestra un resultado, la cámara espera.
  Future<void> leer(String token) async {
    if (state is! Mirando) return;
    state = const Consultando();
    try {
      final lectura = await ref.read(clientesRepositoryProvider).leerQr(token);
      if (!ref.mounted) return;
      state = switch (lectura) {
        YaEsCliente(:final ficha) => ListoParaFicha(ficha, recienAfiliado: false),
        _ => Leido(lectura, token),
      };
    } on Object catch (error) {
      if (ref.mounted) state = LecturaFallida(mensajeAlLeerQr(error));
    }
  }

  /// "Sí, afiliar": la persona confirmó que es ella.
  Future<void> afiliar() async {
    final actual = state;
    if (actual is! Leido || actual.lectura is! PorAfiliar) return;
    state = Afiliando(actual.lectura as PorAfiliar);
    try {
      final (ficha, yaEstaba) = await ref.read(clientesRepositoryProvider).afiliar(actual.token);
      if (!ref.mounted) return;
      ref.invalidate(copiaDeClientesProvider);
      state = ListoParaFicha(ficha, recienAfiliado: !yaEstaba);
    } on Object catch (error) {
      if (ref.mounted) state = LecturaFallida(mensajeAlAfiliar(error));
    }
  }

  /// "No es" o "Escanear otro": vuelve a la cámara.
  void otraVez() => state = const Mirando();
}
