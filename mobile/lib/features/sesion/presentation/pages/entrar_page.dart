import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/sesion_providers.dart';
import '../../../../core/router/rutas.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/estado_sesion.dart';
import '../../domain/reglas/reglas_ingreso.dart';
import '../widgets/campo_pin.dart';
import '../widgets/formulario_con_espera.dart';

/// Entrar con celular y PIN (HU-02-01). Quien llega por primera vez crea su cuenta
/// (HU-04-01); si ya la tenía, vuelve aquí con [celular] ya escrito.
class EntrarPage extends ConsumerStatefulWidget {
  const EntrarPage({super.key, this.celular});

  final String? celular;

  @override
  ConsumerState<EntrarPage> createState() => _EntrarPageState();
}

class _EntrarPageState extends ConsumerState<EntrarPage> {
  late final _celular = TextEditingController(text: widget.celular);
  final _pin = TextEditingController();

  @override
  void didUpdateWidget(EntrarPage anterior) {
    super.didUpdateWidget(anterior);
    final celular = widget.celular;
    if (celular != null && celular != anterior.celular) _celular.text = celular;
  }

  @override
  void dispose() {
    _celular.dispose();
    _pin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(estadoSesionProvider);
    return Scaffold(
      body: FormularioConEspera(
        titulo: '¡Hola, veci!',
        explicacion: 'Entra con tu celular y tu PIN.',
        avisoInicial: estado is SinSesion ? estado.aviso : null,
        textoBoton: 'Entrar',
        validar: () => problemaConCelular(_celular.text) ?? problemaConPin(_pin.text),
        enviar: () => ref.read(gestorSesionProvider).entrarConPin(_celular.text, _pin.text),
        debajoDelBoton: [
          TextButton(
            onPressed: () => context.push(Rutas.registro),
            child: const Text('¿Primera vez? Crea tu cuenta'),
          ),
        ],
        campos: [
          TextField(
            controller: _celular,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumberNational],
            decoration: const InputDecoration(labelText: 'Celular', hintText: '310 000 0102'),
          ),
          const SizedBox(height: VeciEspacio.m),
          CampoPin(
            etiqueta: 'PIN',
            controlador: _pin,
            ayuda: 'Los 6 números con los que entras a VECI.',
          ),
        ],
      ),
    );
  }
}
