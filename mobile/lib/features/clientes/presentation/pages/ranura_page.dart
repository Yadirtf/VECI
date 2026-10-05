import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../domain/entities/cliente_en_caja.dart';
import '../../domain/reglas/consulta_caja.dart';
import '../providers/copia_clientes_controller.dart';
import '../rutas_clientes.dart';
import '../widgets/resultados_ranura.dart';

/// "La ranura de quien sigue" (HU-04-05): un solo campo en el mostrador para el
/// nombre, el celular o el documento, y el botón de escanear. Busca en la copia del
/// celular mientras se escribe, así sirve sin internet.
class RanuraPage extends ConsumerStatefulWidget {
  const RanuraPage({super.key});

  @override
  ConsumerState<RanuraPage> createState() => _RanuraPageState();
}

class _RanuraPageState extends ConsumerState<RanuraPage> {
  final _campo = TextEditingController();

  @override
  void initState() {
    super.initState();
    _campo.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _campo.dispose();
    super.dispose();
  }

  void _abrir(ClienteEnCaja cliente) => context.push(RutasClientes.fichaDe(cliente.clienteId));

  @override
  Widget build(BuildContext context) {
    final copia = ref.watch(copiaDeClientesProvider);
    final consulta = inferirConsulta(_campo.text);
    return Scaffold(
      appBar: AppBar(title: const Text('¿Quién sigue?')),
      body: Column(
        children: [
          Expanded(
            child: switch (copia) {
              AsyncValue(:final value?) => ResultadosRanura(
                copia: value,
                consulta: consulta,
                ahora: ref.watch(relojProvider)(),
                alAbrir: _abrir,
                alRegistrar: () => context.push(RutasClientes.registrarCon(consulta.texto)),
              ),
              AsyncError() => const Center(
                child: Text('No pudimos abrir tus clientes. Intenta otra vez, veci.'),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
          VeciMostrador(
            children: [
              TextField(
                controller: _campo,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: 'Nombre, celular o documento',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _campo.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Borrar',
                          icon: const Icon(Icons.close),
                          onPressed: _campo.clear,
                        ),
                ),
              ),
              VeciBoton(
                texto: 'Escanear QR',
                icono: Icons.qr_code_scanner,
                alTocar: () => context.push(RutasClientes.escanear),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
