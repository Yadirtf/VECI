import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_pin.dart';
import '../../domain/entities/registro.dart';
import '../../domain/reglas/reglas_registro.dart';

typedef AlCambiar = void Function(BorradorRegistro nuevo);

/// Pregunta grande arriba, una línea que explica para qué y la respuesta debajo.
class Pregunta extends StatelessWidget {
  const Pregunta({super.key, required this.titulo, required this.children, this.explicacion});

  final String titulo;
  final String? explicacion;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final explicacion = this.explicacion;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: VeciTexto.grande,
            fontWeight: VeciPeso.fuerte,
            color: VeciColores.selvaOscuro,
            height: 1.1,
          ),
        ),
        if (explicacion != null) ...[
          const SizedBox(height: VeciEspacio.s),
          Text(explicacion, style: const TextStyle(fontSize: VeciTexto.cuerpo)),
        ],
        const SizedBox(height: VeciEspacio.l),
        ...children,
      ],
    );
  }
}

class PreguntaCelular extends StatelessWidget {
  const PreguntaCelular({super.key, required this.borrador, required this.alCambiar});

  final BorradorRegistro borrador;
  final AlCambiar alCambiar;

  @override
  Widget build(BuildContext context) => Pregunta(
    titulo: '¿Cuál es tu celular?',
    explicacion: 'Con tu celular y tu PIN entras a VECI.',
    children: [
      TextFormField(
        initialValue: borrador.celular,
        autofocus: true,
        keyboardType: TextInputType.phone,
        autofillHints: const [AutofillHints.telephoneNumberNational],
        maxLength: 13,
        decoration: const InputDecoration(labelText: 'Celular', hintText: '315 777 8888'),
        onChanged: (v) => alCambiar(borrador.copiar(celular: v)),
      ),
    ],
  );
}

class PreguntaNombre extends StatelessWidget {
  const PreguntaNombre({super.key, required this.borrador, required this.alCambiar});

  final BorradorRegistro borrador;
  final AlCambiar alCambiar;

  @override
  Widget build(BuildContext context) => Pregunta(
    titulo: '¿Cómo te llamas?',
    explicacion: 'Así te saluda el negocio cuando muestres tu QR.',
    children: [
      TextFormField(
        initialValue: borrador.nombres,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        maxLength: 80,
        decoration: const InputDecoration(labelText: 'Nombre'),
        onChanged: (v) => alCambiar(borrador.copiar(nombres: v)),
      ),
      TextFormField(
        initialValue: borrador.apellidos,
        textCapitalization: TextCapitalization.words,
        maxLength: 80,
        decoration: const InputDecoration(labelText: 'Apellidos (si quieres)'),
        onChanged: (v) => alCambiar(borrador.copiar(apellidos: v)),
      ),
    ],
  );
}

class PreguntaDocumento extends StatelessWidget {
  const PreguntaDocumento({
    super.key,
    required this.borrador,
    required this.tipos,
    required this.alCambiar,
  });

  final BorradorRegistro borrador;
  final List<TipoDocumento> tipos;
  final AlCambiar alCambiar;

  @override
  Widget build(BuildContext context) {
    final tipo = tipoElegido(borrador, tipos);
    final numeros = esSoloNumeros(tipo);
    return Pregunta(
      titulo: '¿Cuál es tu documento?',
      explicacion: 'Cada negocio solo ve los últimos 4 números.',
      children: [
        Wrap(
          spacing: VeciEspacio.s,
          runSpacing: VeciEspacio.s,
          children: [
            for (final t in tipos)
              ChoiceChip(
                label: Text(t.nombre),
                selected: t.codigo == borrador.tipoDocumento,
                onSelected: (_) => alCambiar(borrador.copiar(tipoDocumento: t.codigo)),
              ),
          ],
        ),
        const SizedBox(height: VeciEspacio.m),
        TextFormField(
          key: ValueKey(borrador.tipoDocumento),
          initialValue: borrador.numeroDocumento,
          keyboardType: numeros ? TextInputType.number : TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [if (numeros) FilteringTextInputFormatter.digitsOnly],
          maxLength: 20,
          decoration: InputDecoration(labelText: 'Número de ${tipo?.nombre ?? 'documento'}'),
          onChanged: (v) => alCambiar(borrador.copiar(numeroDocumento: v)),
        ),
      ],
    );
  }
}

/// El PIN y su repetición; las casillas se perforan al escribir (VeciPin).
class PreguntaPin extends StatefulWidget {
  const PreguntaPin({super.key, required this.borrador, required this.alCambiar});

  final BorradorRegistro borrador;
  final AlCambiar alCambiar;

  @override
  State<PreguntaPin> createState() => _PreguntaPinState();
}

class _PreguntaPinState extends State<PreguntaPin> {
  late final _pin = TextEditingController(text: widget.borrador.pin);
  late final _repetido = TextEditingController(text: widget.borrador.pinRepetido);

  @override
  void initState() {
    super.initState();
    _pin.addListener(_avisar);
    _repetido.addListener(_avisar);
  }

  void _avisar() {
    final b = widget.borrador;
    if (b.pin == _pin.text && b.pinRepetido == _repetido.text) return;
    widget.alCambiar(b.copiar(pin: _pin.text, pinRepetido: _repetido.text));
  }

  @override
  void dispose() {
    _pin.dispose();
    _repetido.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Pregunta(
    titulo: 'Último paso: crea tu PIN',
    explicacion: 'Son 6 números y solo tú los sabes. Con ellos entras a VECI.',
    children: [
      VeciPin(
        etiqueta: 'Tu PIN',
        controlador: _pin,
        ayuda: 'Evita fechas, 123456 o el mismo número repetido.',
      ),
      const SizedBox(height: VeciEspacio.m),
      VeciPin(etiqueta: 'Escríbelo otra vez', controlador: _repetido),
    ],
  );
}
