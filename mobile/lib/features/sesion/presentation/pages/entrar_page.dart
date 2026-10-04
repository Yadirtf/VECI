import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/sesion_providers.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/estado_sesion.dart';
import '../../domain/reglas/reglas_ingreso.dart';
import '../widgets/campo_pin.dart';
import '../widgets/formulario_con_espera.dart';

/// Entrar con celular y PIN (HU-02-01).
class EntrarPage extends ConsumerStatefulWidget {
  const EntrarPage({super.key});

  @override
  ConsumerState<EntrarPage> createState() => _EntrarPageState();
}

class _EntrarPageState extends ConsumerState<EntrarPage> {
  final _celular = TextEditingController();
  final _pin = TextEditingController();

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
      body: SafeArea(
        child: FormularioConEspera(
          titulo: '¡Hola, veci!',
          explicacion: 'Entra con tu celular y tu PIN.',
          avisoInicial: estado is SinSesion ? estado.aviso : null,
          textoBoton: 'Entrar',
          validar: () => problemaConCelular(_celular.text) ?? problemaConPin(_pin.text),
          enviar: () => ref.read(gestorSesionProvider).entrarConPin(_celular.text, _pin.text),
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
      ),
    );
  }
}
