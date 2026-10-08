import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/alta.dart';
import '../../domain/reglas/reglas_alta.dart';

typedef AlCambiar = void Function(BorradorAlta nuevo);

/// Pregunta grande arriba y su respuesta debajo.
class Pregunta extends StatelessWidget {
  const Pregunta({super.key, required this.titulo, required this.children});

  final String titulo;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
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
      const SizedBox(height: VeciEspacio.l),
      ...children,
    ],
  );
}

/// Opción redonda que se toca con el pulgar; no se despliega ninguna lista.
class Bola extends StatelessWidget {
  const Bola({super.key, required this.texto, required this.activa, required this.alTocar});

  final String texto;
  final bool activa;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: activa,
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: alTocar,
      child: Container(
        width: 104,
        height: 104,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(VeciEspacio.s),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activa ? VeciColores.selva : VeciColores.superficie,
          border: Border.all(color: activa ? VeciColores.selva : VeciColores.borde, width: 2),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: VeciPeso.medio,
            color: activa ? VeciColores.superficie : VeciColores.selvaOscuro,
          ),
        ),
      ),
    ),
  );
}

class PreguntaTipo extends StatelessWidget {
  const PreguntaTipo({
    super.key,
    required this.borrador,
    required this.tipos,
    required this.alCambiar,
  });

  final BorradorAlta borrador;
  final List<TipoDeNegocio> tipos;
  final AlCambiar alCambiar;

  @override
  Widget build(BuildContext context) {
    final elegido = tipos.where((t) => t.codigo == borrador.tipoNegocio).firstOrNull;
    return Pregunta(
      titulo: '¿Qué vendes?',
      children: [
        Wrap(
          spacing: VeciEspacio.m,
          runSpacing: VeciEspacio.m,
          children: [
            for (final (i, t) in tipos.indexed)
              Padding(
                padding: EdgeInsets.only(top: i.isOdd ? VeciEspacio.l : 0),
                child: Bola(
                  texto: t.nombre,
                  activa: t.codigo == borrador.tipoNegocio,
                  alTocar: () => alCambiar(borrador.copiar(tipoNegocio: t.codigo)),
                ),
              ),
          ],
        ),
        if (elegido != null && elegido.servicios.isNotEmpty) ...[
          const SizedBox(height: VeciEspacio.l),
          Text(
            'Tu negocio nace con ${elegido.servicios.join(', ')}. Las horas las eliges después.',
          ),
        ],
      ],
    );
  }
}

class PreguntaDocumento extends StatelessWidget {
  const PreguntaDocumento({super.key, required this.borrador, required this.alCambiar});

  final BorradorAlta borrador;
  final AlCambiar alCambiar;

  @override
  Widget build(BuildContext context) {
    final digitos = soloDigitos(borrador.documento);
    final listo = borrador.esNit && RegExp(r'^\d{8,9}$').hasMatch(digitos);
    return Pregunta(
      titulo: '¿Con qué número está registrado?',
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('NIT')),
            ButtonSegment(value: false, label: Text('Cédula')),
          ],
          selected: {borrador.esNit},
          onSelectionChanged: (valor) => alCambiar(borrador.copiar(esNit: valor.first)),
        ),
        const SizedBox(height: VeciEspacio.m),
        TextFormField(
          initialValue: borrador.documento,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: borrador.esNit ? 9 : 10,
          decoration: InputDecoration(
            labelText: borrador.esNit ? 'NIT, solo los 9 números' : 'Número de cédula',
            suffixText: borrador.esNit ? '-${listo ? digitoVerificacion(digitos) : '?'}' : null,
          ),
          onChanged: (valor) => alCambiar(borrador.copiar(documento: valor)),
        ),
        if (listo)
          Text(
            'El dígito de verificación es ${digitoVerificacion(digitos)}. Lo pusimos nosotros, veci.',
            style: const TextStyle(color: VeciColores.selvaOscuro),
          ),
      ],
    );
  }
}

/// Campo de texto de una sola pregunta (nombre o celular).
class PreguntaTexto extends StatelessWidget {
  const PreguntaTexto({
    super.key,
    required this.titulo,
    required this.etiqueta,
    required this.valor,
    required this.alCambiar,
    this.celular = false,
  });

  final String titulo;
  final String etiqueta;
  final String valor;
  final ValueChanged<String> alCambiar;
  final bool celular;

  @override
  Widget build(BuildContext context) => Pregunta(
    titulo: titulo,
    children: [
      TextFormField(
        initialValue: valor,
        autofocus: true,
        keyboardType: celular ? TextInputType.phone : TextInputType.text,
        textCapitalization: celular ? TextCapitalization.none : TextCapitalization.words,
        maxLength: celular ? 13 : 120,
        decoration: InputDecoration(labelText: etiqueta),
        onChanged: alCambiar,
      ),
    ],
  );
}

/// Dónde queda el negocio: solo los municipios donde VECI ya presta el servicio.
class PreguntaLugar extends StatelessWidget {
  const PreguntaLugar({
    super.key,
    required this.borrador,
    required this.municipios,
    required this.alCambiar,
  });

  final BorradorAlta borrador;
  final List<Municipio> municipios;
  final AlCambiar alCambiar;

  @override
  Widget build(BuildContext context) => Pregunta(
    titulo: '¿En qué municipio queda?',
    children: [
      Wrap(
        spacing: VeciEspacio.m,
        runSpacing: VeciEspacio.m,
        children: [
          for (final m in municipios)
            Bola(
              texto: m.nombre,
              activa: m.id == borrador.municipioId,
              alTocar: () => alCambiar(borrador.copiar(municipioId: m.id)),
            ),
        ],
      ),
      const SizedBox(height: VeciEspacio.l),
      const Text('Por ahora VECI está en Mocoa. Pronto llegamos a más municipios del Putumayo.'),
    ],
  );
}
