import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/lectura_qr.dart';
import '../../domain/entities/registro_asistido.dart';

/// Tipo y número de documento: lo primero del registro asistido.
class SeccionDocumento extends StatelessWidget {
  const SeccionDocumento({
    super.key,
    required this.tipos,
    required this.tipo,
    required this.numero,
    required this.alCambiarTipo,
    required this.editable,
  });

  final List<TipoDocumento> tipos;
  final TipoDocumento? tipo;
  final TextEditingController numero;
  final ValueChanged<TipoDocumento?> alCambiarTipo;
  final bool editable;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DropdownButtonFormField<TipoDocumento>(
        initialValue: tipo,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Tipo de documento'),
        items: [for (final t in tipos) DropdownMenuItem(value: t, child: Text(t.nombre))],
        onChanged: editable ? alCambiarTipo : null,
      ),
      const SizedBox(height: VeciEspacio.m),
      TextField(
        controller: numero,
        enabled: editable,
        keyboardType: tipo?.codigo == 'PASSPORT' ? TextInputType.text : TextInputType.number,
        decoration: const InputDecoration(labelText: 'Número de documento'),
      ),
    ],
  );
}

/// La persona ya está en VECI: se muestra enmascarada para confirmar.
class PersonaYaEnVeci extends StatelessWidget {
  const PersonaYaEnVeci({super.key, required this.persona});

  final PersonaEncontrada persona;

  @override
  Widget build(BuildContext context) => VeciTarjeta(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          persona.clienteId == null ? 'Ya está en VECI' : 'Ya es cliente de tu negocio',
          style: const TextStyle(color: VeciColores.tintaSuave),
        ),
        Text(
          persona.nombre,
          style: const TextStyle(fontSize: VeciTexto.grande, fontWeight: VeciPeso.fuerte),
        ),
        Text('Documento ${persona.documento}', style: const TextStyle(fontSize: VeciTexto.cuerpo)),
      ],
    ),
  );
}

/// Nombre, apellidos (opcional) y celular de alguien nuevo en VECI.
class DatosNuevos extends StatelessWidget {
  const DatosNuevos({
    super.key,
    required this.nombres,
    required this.apellidos,
    required this.celular,
  });

  final TextEditingController nombres;
  final TextEditingController apellidos;
  final TextEditingController celular;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        'No está en VECI. Anota sus datos:',
        style: TextStyle(fontSize: VeciTexto.cuerpo, fontWeight: VeciPeso.medio),
      ),
      const SizedBox(height: VeciEspacio.s),
      TextField(
        controller: nombres,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Nombres'),
      ),
      const SizedBox(height: VeciEspacio.m),
      TextField(
        controller: apellidos,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(labelText: 'Apellidos (si quiere)'),
      ),
      const SizedBox(height: VeciEspacio.m),
      TextField(
        controller: celular,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'Celular', hintText: '310 000 0102'),
      ),
    ],
  );
}
