import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/catalogo.dart';
import '../../domain/reglas/reglas_venta.dart';

/// Lo que la cajera elige: qué tiquetera y cómo pagó (HU-05-02).
class EleccionDeVenta extends StatelessWidget {
  const EleccionDeVenta({
    super.key,
    required this.catalogo,
    required this.tipoId,
    required this.medio,
    required this.canal,
    required this.referencia,
    required this.alElegirTipo,
    required this.alElegirMedio,
    required this.alElegirCanal,
  });

  final CatalogoDeVenta catalogo;
  final String? tipoId;
  final String? medio;
  final String? canal;
  final TextEditingController referencia;
  final ValueChanged<String> alElegirTipo;
  final ValueChanged<String> alElegirMedio;
  final ValueChanged<String> alElegirCanal;

  @override
  Widget build(BuildContext context) {
    final elegido = catalogo.medios.where((m) => m.codigo == medio).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Titulo('¿Cuál lleva?'),
        RadioGroup<String>(
          groupValue: tipoId,
          onChanged: (v) => v == null ? null : alElegirTipo(v),
          child: Column(children: [for (final t in catalogo.tipos) _OpcionTipo(t)]),
        ),
        const SizedBox(height: VeciEspacio.m),
        const _Titulo('¿Cómo pagó?'),
        _Fichas(
          opciones: {for (final m in catalogo.medios) m.codigo: m.nombre},
          elegida: medio,
          alElegir: alElegirMedio,
        ),
        if (elegido != null && elegido.necesitaCanal) ...[
          const SizedBox(height: VeciEspacio.m),
          const _Titulo('¿Por dónde llegó?'),
          _Fichas(
            opciones: {for (final c in elegido.canales) c.codigo: c.nombre},
            elegida: canal,
            alElegir: alElegirCanal,
          ),
          const SizedBox(height: VeciEspacio.s),
          TextField(
            controller: referencia,
            maxLength: 60,
            decoration: const InputDecoration(labelText: 'Referencia (opcional)'),
          ),
        ],
      ],
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: VeciEspacio.s),
    child: Text(
      texto,
      style: const TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.fuerte),
    ),
  );
}

class _OpcionTipo extends StatelessWidget {
  const _OpcionTipo(this.tipo);

  final TipoEnVenta tipo;

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: VeciEspacio.s),
    child: RadioListTile<String>(
      value: tipo.tipoId,
      title: Text(
        '${tipo.nombre} · ${pesos(tipo.precio)}',
        style: const TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
      ),
      subtitle: Text('${tipo.unidad.de(tipo.unidades)} · sirve ${tipo.vigenciaDias} días'),
    ),
  );
}

class _Fichas extends StatelessWidget {
  const _Fichas({required this.opciones, required this.elegida, required this.alElegir});

  final Map<String, String> opciones;
  final String? elegida;
  final ValueChanged<String> alElegir;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: VeciEspacio.s,
    runSpacing: VeciEspacio.s,
    children: [
      for (final MapEntry(key: codigo, value: nombre) in opciones.entries)
        ChoiceChip(
          label: Text(nombre, style: const TextStyle(fontSize: VeciTexto.cuerpo)),
          selected: codigo == elegida,
          onSelected: (_) => alElegir(codigo),
        ),
    ],
  );
}
