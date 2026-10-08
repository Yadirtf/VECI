import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_encabezado.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/estado_de_cuenta.dart';
import '../providers/tiqueteras_providers.dart';
import '../widgets/saldos.dart';
import '../widgets/textos_tiqueteras.dart';

/// Lo que le queda a la persona en cada negocio (HU-05-02, HU-05-03): el saldo por
/// unidad y sus cartones. Se ve sin internet con la última copia.
class TusTiqueterasPage extends ConsumerWidget {
  const TusTiqueterasPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saldos = ref.watch(misTiqueterasProvider);
    return Scaffold(
      body: Column(
        children: [
          VeciEncabezado(
            antetitulo: 'Tus tiqueteras',
            titulo: 'Lo que te queda',
            explicacion: 'Arriba va la que se gasta primero: la que vence antes.',
            acciones: [
              if (context.canPop())
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: VeciColores.crema),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  onPressed: context.pop,
                ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(misTiqueterasProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(VeciEspacio.l),
                children: switch (saldos) {
                  AsyncData(:final value) => _negocios(value),
                  AsyncError(:final error) => [
                    VeciAviso(tono: TonoAviso.error, mensaje: _sinCopia(error)),
                  ],
                  _ => const [Center(child: CircularProgressIndicator())],
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sinCopia(Object error) => mensajeDeSaldo(error) == sinSenalParaSaldo
      ? 'Para ver tu saldo la primera vez necesitas internet. Conéctate, veci.'
      : mensajeDeSaldo(error);

  List<Widget> _negocios(MisSaldos saldos) => [
    if (saldos.sinSenal) ...[
      const VeciAviso(tono: TonoAviso.aviso, mensaje: 'Sin señal: te mostramos lo guardado.'),
      const SizedBox(height: VeciEspacio.m),
    ],
    if (saldos.negocios.isEmpty)
      const VeciTarjeta(
        perforado: true,
        child: Text(
          'Aún no tienes tiqueteras. Cuando compres una en tu negocio, aparece aquí.',
          style: TextStyle(fontSize: VeciTexto.cuerpo),
        ),
      ),
    for (final negocio in saldos.negocios) _Negocio(negocio),
  ];
}

class _Negocio extends StatelessWidget {
  const _Negocio(this.negocio);

  final SaldoEnNegocio negocio;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: VeciEspacio.l),
    child: VeciTarjeta(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            negocio.comercio,
            style: const TextStyle(fontSize: VeciTexto.titulo, fontWeight: VeciPeso.fuerte),
          ),
          const SizedBox(height: VeciEspacio.m),
          SaldosYCartones(cuenta: negocio.cuenta, vacio: 'Ya no te quedan unidades aquí.'),
        ],
      ),
    ),
  );
}
