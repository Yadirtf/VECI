import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/sesion_providers.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../domain/entities/estado_sesion.dart';
import '../../domain/entities/sesion.dart';
import '../../domain/reglas/reglas_ingreso.dart';
import '../widgets/mensaje_de_fallo.dart';

/// Una persona puede ser cajera en un negocio y cliente en otro: elige con cuál sigue (HU-02-03).
class ElegirNegocioPage extends ConsumerStatefulWidget {
  const ElegirNegocioPage({super.key});

  @override
  ConsumerState<ElegirNegocioPage> createState() => _ElegirNegocioPageState();
}

class _ElegirNegocioPageState extends ConsumerState<ElegirNegocioPage> {
  String? _eligiendo;
  String? _problema;

  Future<void> _elegir(String comercioId) async {
    setState(() {
      _eligiendo = comercioId;
      _problema = null;
    });
    try {
      await ref.read(gestorSesionProvider).elegirComercio(comercioId);
    } on Object catch (error) {
      if (mounted) setState(() => _problema = mensajeDeFallo(error));
    } finally {
      if (mounted) setState(() => _eligiendo = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(estadoSesionProvider);
    final sesion = estado is SesionActiva ? estado.sesion : null;
    final textos = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tus negocios'),
        actions: [
          TextButton(onPressed: ref.read(gestorSesionProvider).salir, child: const Text('Salir')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          VeciEspacio.l,
          VeciEspacio.xl,
          VeciEspacio.l,
          VeciEspacio.l,
        ),
        children: [
          Text('Hola, ${sesion?.nombre ?? 'veci'}', style: textos.headlineSmall),
          const SizedBox(height: VeciEspacio.s),
          Text(_explicacion(sesion), style: textos.titleMedium),
          const SizedBox(height: VeciEspacio.l),
          if (_problema != null) VeciAviso(tono: TonoAviso.error, mensaje: _problema!),
          for (final espacio in sesion?.espacios ?? const <Espacio>[]) _tarjeta(espacio),
          const SizedBox(height: VeciEspacio.m),
          OutlinedButton.icon(
            onPressed: () => context.push(Rutas.registrarNegocio),
            icon: const Icon(Icons.storefront),
            label: Text(
              (sesion?.espacios.isEmpty ?? true)
                  ? 'Registrar mi negocio'
                  : 'Registrar otro negocio',
            ),
          ),
        ],
      ),
    );
  }

  String _explicacion(SesionAbierta? sesion) => (sesion?.espacios.isEmpty ?? true)
      ? 'Aún no estás en ningún negocio. Pídele al negocio que te invite, o registra el tuyo.'
      : '¿Con cuál negocio vas a trabajar?';

  Widget _tarjeta(Espacio espacio) => Card(
    margin: const EdgeInsets.only(bottom: VeciEspacio.m),
    child: ListTile(
      minTileHeight: VeciToque.botonGrande,
      title: Text(espacio.nombre, style: const TextStyle(fontSize: VeciTexto.subtitulo)),
      subtitle: Text(_rol(espacio)),
      trailing: _eligiendo == espacio.comercioId
          ? const CircularProgressIndicator()
          : const Icon(Icons.chevron_right),
      onTap: _eligiendo == null ? () => _elegir(espacio.comercioId) : null,
    ),
  );

  String _rol(Espacio e) {
    if (e.invitacionPendiente) return 'Te invitaron como cajero';
    if (e.roles.contains('OWNER')) return 'Propietario';
    return esDeLaCaja(e) ? 'Cajero' : 'Cliente';
  }
}
