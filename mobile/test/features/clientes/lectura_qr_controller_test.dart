import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veci/core/di/clientes_providers.dart';
import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/clientes/domain/entities/lectura_qr.dart';
import 'package:veci/features/clientes/presentation/providers/lectura_qr_controller.dart';
import 'package:veci/features/clientes/presentation/widgets/mensajes_clientes.dart';

import 'clientes_dobles.dart';

void main() {
  late RepositorioClientesFalso repositorio;
  late ProviderContainer contenedor;

  setUp(() {
    repositorio = RepositorioClientesFalso();
    contenedor = ProviderContainer(
      overrides: [clientesRepositoryProvider.overrideWithValue(repositorio)],
    );
    contenedor.listen(lecturaQrProvider, (_, _) {});
  });

  tearDown(() => contenedor.dispose());

  LecturaQrController control() => contenedor.read(lecturaQrProvider.notifier);
  PasoLectura paso() => contenedor.read(lecturaQrProvider);

  test('persona por afiliar: espera la confirmación y luego afilia con el mismo token', () async {
    await control().leer('VP1.abc.firma');
    expect(paso(), isA<Leido>().having((p) => p.lectura, 'lectura', isA<PorAfiliar>()));

    await control().afiliar();

    expect(repositorio.afiliados, ['VP1.abc.firma']);
    expect(paso(), isA<ListoParaFicha>().having((p) => p.recienAfiliado, 'recién', isTrue));
  });

  test('si ya es cliente va directo a su ficha', () async {
    repositorio.lectura = YaEsCliente(fichaDePrueba());

    await control().leer('VP1.abc.firma');

    expect(paso(), isA<ListoParaFicha>().having((p) => p.recienAfiliado, 'recién', isFalse));
  });

  test('cada QR que no sirve tiene su mensaje', () async {
    final casos = {
      const QrCambiado(): 'Este QR ya no sirve: fue cambiado. Pídele que abra Mi QR en su app.',
      const QrDeOtroNegocio(): 'Este QR es de otro negocio. Pídele su QR personal de VECI.',
      const QrAjeno(): 'Este QR no es de VECI.',
    };
    for (final MapEntry(key: lectura, value: mensaje) in casos.entries) {
      repositorio.lectura = lectura;
      control().otraVez();
      await control().leer('x');
      expect(paso(), isA<Leido>());
      expect(mensajeDeLectura((paso() as Leido).lectura), mensaje);
    }
  });

  test('"No es" vuelve a la cámara sin afiliar', () async {
    await control().leer('VP1.abc.firma');
    control().otraVez();

    expect(paso(), isA<Mirando>());
    expect(repositorio.afiliados, isEmpty);
  });

  test('sin internet hace una pausa honesta', () async {
    await control().leer('VP1.abc.firma');
    repositorio.fallo = const SinConexion();

    await control().afiliar();

    expect(paso(), isA<LecturaFallida>().having((p) => p.mensaje, 'mensaje', pausaParaAfiliar));
  });

  test('no lee otro QR mientras muestra un resultado', () async {
    await control().leer('uno');
    repositorio.lectura = const QrAjeno();

    await control().leer('dos');

    expect((paso() as Leido).token, 'uno');
  });
}
