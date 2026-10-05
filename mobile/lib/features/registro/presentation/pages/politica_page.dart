import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/registro.dart';
import '../providers/registro_providers.dart';

/// La política de datos completa: cada sección con su "En palabras de vecino" arriba
/// y el texto legal debajo.
class PoliticaPage extends ConsumerWidget {
  const PoliticaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final politica = ref.watch(politicaDeDatosProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Política de datos')),
      body: switch (politica) {
        AsyncData(:final value) => _Secciones(politica: value),
        AsyncError() => const Padding(
          padding: EdgeInsets.all(VeciEspacio.l),
          child: VeciAviso(
            tono: TonoAviso.error,
            mensaje: 'Para leer la política necesitas internet. Conéctate y vuelve a entrar.',
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Secciones extends StatelessWidget {
  const _Secciones({required this.politica});

  final PoliticaDeDatos politica;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(VeciEspacio.l),
    children: [
      Text('Versión ${politica.version}', style: const TextStyle(color: VeciColores.tintaSuave)),
      const SizedBox(height: VeciEspacio.m),
      for (final seccion in politica.secciones) ...[
        Text(
          seccion.titulo,
          style: const TextStyle(
            fontSize: VeciTexto.titulo,
            fontWeight: VeciPeso.fuerte,
            color: VeciColores.selvaOscuro,
          ),
        ),
        const SizedBox(height: VeciEspacio.s),
        VeciTarjeta(
          color: VeciColores.selvaClaro,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('En palabras de vecino', style: TextStyle(fontWeight: VeciPeso.fuerte)),
              const SizedBox(height: VeciEspacio.xs),
              Text(seccion.enPalabrasDeVecino, style: const TextStyle(fontSize: VeciTexto.cuerpo)),
            ],
          ),
        ),
        const SizedBox(height: VeciEspacio.s),
        Text(seccion.texto, style: const TextStyle(fontSize: VeciTexto.pequeno)),
        const SizedBox(height: VeciEspacio.xl),
      ],
    ],
  );
}
