import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/sesion_providers.dart';
import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/estado_sesion.dart';
import '../../domain/reglas/reglas_ingreso.dart';
import '../widgets/campo_pin.dart';
import '../widgets/formulario_con_espera.dart';

/// Tras entrar con un PIN temporal, la persona crea el suyo (HU-02-04, HU-02-05).
class PinNuevoPage extends ConsumerStatefulWidget {
  const PinNuevoPage({super.key});

  @override
  ConsumerState<PinNuevoPage> createState() => _PinNuevoPageState();
}

class _PinNuevoPageState extends ConsumerState<PinNuevoPage> {
  final _pin = TextEditingController();
  final _repetido = TextEditingController();

  @override
  void dispose() {
    _pin.dispose();
    _repetido.dispose();
    super.dispose();
  }

  String? _validar() {
    final problema = problemaConPin(_pin.text);
    if (problema != null) return problema;
    return _pin.text == _repetido.text ? null : 'Los dos PIN no coinciden.';
  }

  @override
  Widget build(BuildContext context) {
    final estado = ref.watch(estadoSesionProvider);
    final nombre = estado is CambioDePin ? estado.nombre : 'veci';
    return Scaffold(
      body: FormularioConEspera(
        titulo: 'Hola, $nombre',
        explicacion: 'Entraste con un PIN temporal. Crea tu PIN de 6 números; solo tú lo sabrás.',
        textoBoton: 'Guardar mi PIN',
        validar: _validar,
        enviar: () => ref.read(gestorSesionProvider).crearPinNuevo(_pin.text),
        campos: [
          CampoPin(
            etiqueta: 'PIN nuevo',
            controlador: _pin,
            ayuda: 'Evita fechas, 123456 o el mismo número repetido.',
          ),
          const SizedBox(height: VeciEspacio.m),
          CampoPin(etiqueta: 'Escríbelo otra vez', controlador: _repetido),
        ],
      ),
    );
  }
}
