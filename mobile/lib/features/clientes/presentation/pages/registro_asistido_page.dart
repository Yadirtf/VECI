import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_mostrador.dart';
import '../../domain/entities/registro_asistido.dart';
import '../../domain/reglas/consulta_caja.dart';
import '../../domain/reglas/reglas_registro.dart';
import '../providers/registro_asistido_controller.dart';
import '../rutas_clientes.dart';
import '../widgets/mensajes_clientes.dart';
import '../widgets/pin_para_dictar.dart';
import '../widgets/politica_en_corto.dart';
import '../widgets/secciones_registro.dart';
import 'ficha_cliente_page.dart';

/// Registro asistido en una sola pantalla (HU-04-04): primero el documento; si la
/// persona ya está en VECI se afilia, si no se anotan sus datos, se le lee la
/// política "en corto" y "Sí aceptó · Registrar" es la confirmación.
class RegistroAsistidoPage extends ConsumerStatefulWidget {
  const RegistroAsistidoPage({super.key, this.datoInicial = ''});

  /// Lo escrito en la ranura; va al campo que corresponde.
  final String datoInicial;

  @override
  ConsumerState<RegistroAsistidoPage> createState() => _RegistroAsistidoPageState();
}

class _RegistroAsistidoPageState extends ConsumerState<RegistroAsistidoPage> {
  final _numero = TextEditingController();
  final _nombres = TextEditingController();
  final _apellidos = TextEditingController();
  final _celular = TextEditingController();
  TipoDocumento? _tipo;

  @override
  void initState() {
    super.initState();
    final dato = inferirConsulta(widget.datoInicial);
    switch (dato.tipo) {
      case TipoConsulta.celular:
        _celular.text = dato.digitos;
      case TipoConsulta.documento:
        _numero.text = dato.digitos;
      case TipoConsulta.nombre:
        _nombres.text = dato.texto;
    }
  }

  @override
  void dispose() {
    for (final c in [_numero, _nombres, _apellidos, _celular]) {
      c.dispose();
    }
    super.dispose();
  }

  RegistroAsistidoController get _control => ref.read(registroAsistidoProvider.notifier);

  void _irAFicha(String clienteId, AvisoFicha aviso) =>
      context.pushReplacement(RutasClientes.fichaDe(clienteId, aviso: aviso));

  DatosRegistroAsistido _datos(PoliticaEnCorto politica, {bool soloDocumento = false}) {
    String? opcional(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();
    return DatosRegistroAsistido(
      tipoDocumento: _tipo!.codigo,
      numeroDocumento: limpiarDocumento(_numero.text),
      politicaVersionId: politica.id,
      nombres: soloDocumento ? null : opcional(_nombres),
      apellidos: soloDocumento ? null : opcional(_apellidos),
      celular: soloDocumento ? null : soloDigitos(_celular.text),
    );
  }

  void _registrarNuevo(PoliticaEnCorto politica) {
    final problema = problemaConNombres(_nombres.text) ?? problemaConCelular(_celular.text);
    if (problema != null) return _control.avisar(problema);
    _control.registrar(_datos(politica));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(registroAsistidoProvider, (_, estado) {
      final hecho = estado.hecho;
      if (hecho == null || hecho.pinBienvenida != null) return;
      _irAFicha(
        hecho.ficha.clienteId,
        hecho.vinculado ? AvisoFicha.afiliado : AvisoFicha.registrado,
      );
    });
    final estado = ref.watch(registroAsistidoProvider);
    final hecho = estado.hecho;
    final pin = hecho?.pinBienvenida;
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar cliente')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(VeciEspacio.m),
              children: hecho != null && pin != null ? _bienvenida(pin) : _formulario(estado),
            ),
          ),
          VeciMostrador(
            children: hecho != null && pin != null
                ? [_verFicha(hecho.ficha.clienteId, AvisoFicha.registrado)]
                : _acciones(estado),
          ),
        ],
      ),
    );
  }

  List<Widget> _bienvenida(String pin) => [
    const VeciAviso(tono: TonoAviso.exito, mensaje: '¡Listo, veci! Quedó registrado.'),
    const SizedBox(height: VeciEspacio.m),
    PinParaDictar(pin: pin),
  ];

  List<Widget> _formulario(EstadoRegistro estado) {
    final tipos = ref.watch(tiposDeDocumentoProvider);
    final persona = estado.persona;
    return [
      switch (tipos) {
        AsyncData(:final value) => SeccionDocumento(
          tipos: value,
          tipo: _tipo ??= _porDefecto(value),
          numero: _numero,
          alCambiarTipo: (t) => setState(() => _tipo = t),
          editable: estado.paso == PasoRegistro.documento && !estado.ocupado,
        ),
        AsyncError(:final error) => VeciAviso(
          tono: TonoAviso.aviso,
          mensaje: mensajeAlRegistrar(error),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      if (estado.paso != PasoRegistro.documento)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: estado.ocupado ? null : _control.cambiarDocumento,
            child: const Text('Cambiar documento'),
          ),
        ),
      const SizedBox(height: VeciEspacio.m),
      if (persona != null) PersonaYaEnVeci(persona: persona),
      if (estado.paso == PasoRegistro.nueva) ..._datosYPolitica(),
    ];
  }

  static TipoDocumento? _porDefecto(List<TipoDocumento> tipos) {
    if (tipos.isEmpty) return null;
    return tipos.where((t) => t.codigo == 'CC').firstOrNull ?? tipos.first;
  }

  List<Widget> _datosYPolitica() => [
    DatosNuevos(nombres: _nombres, apellidos: _apellidos, celular: _celular),
    const SizedBox(height: VeciEspacio.l),
    switch (ref.watch(politicaEnCortoProvider)) {
      AsyncData(:final value) => PoliticaEnCortoTarjeta(politica: value),
      AsyncError(:final error) => VeciAviso(
        tono: TonoAviso.aviso,
        mensaje: mensajeAlRegistrar(error),
      ),
      _ => const Center(child: CircularProgressIndicator()),
    },
  ];

  List<Widget> _acciones(EstadoRegistro estado) {
    final politica = ref.watch(politicaEnCortoProvider).value;
    final persona = estado.persona;
    final listo = !estado.ocupado && _tipo != null;
    VeciBoton principal(String texto, VoidCallback? accion) => VeciBoton(
      texto: estado.ocupado ? 'Un momento…' : texto,
      grande: true,
      alTocar: listo ? accion : null,
    );
    final problema = estado.problema;
    return [
      if (problema != null) VeciAviso(tono: TonoAviso.error, mensaje: problema),
      if (estado.ofrecerCompartido)
        VeciBoton(
          texto: 'Es el celular compartido de la familia',
          icono: Icons.family_restroom,
          secundario: true,
          alTocar: estado.ocupado ? null : _control.registrarConCelularCompartido,
        ),
      switch (estado.paso) {
        PasoRegistro.encontrada when persona?.clienteId != null => _verFicha(
          persona!.clienteId!,
          AvisoFicha.yaEsCliente,
        ),
        PasoRegistro.encontrada => principal(
          'Afiliar a esta persona',
          politica == null ? null : () => _control.registrar(_datos(politica, soloDocumento: true)),
        ),
        PasoRegistro.nueva => principal(
          'Sí aceptó · Registrar',
          politica == null ? null : () => _registrarNuevo(politica),
        ),
        _ => principal('Revisar documento', () => _control.revisar(_tipo, _numero.text)),
      },
    ];
  }

  Widget _verFicha(String clienteId, AvisoFicha aviso) => VeciBoton(
    texto: 'Ver su ficha',
    icono: Icons.badge_outlined,
    grande: true,
    alTocar: () => _irAFicha(clienteId, aviso),
  );
}
