import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/ficha_cliente.dart';
import 'fechas.dart';
import 'textos_ficha.dart';

/// La ficha del cliente en un papelito: nombre, documento, celular, si usa la app y
/// desde cuándo es cliente. Al cajero le llegan el documento y el celular enmascarados.
class TarjetaFicha extends StatelessWidget {
  const TarjetaFicha({super.key, required this.ficha});

  final FichaCliente ficha;

  @override
  Widget build(BuildContext context) => VeciTarjeta(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ficha.nombre,
          style: const TextStyle(fontSize: VeciTexto.grande, fontWeight: VeciPeso.fuerte),
        ),
        const SizedBox(height: VeciEspacio.m),
        _Dato(nombreDelDocumento(ficha.tipoDocumento), ficha.documento),
        _Dato('Celular', ficha.celular ?? 'No dejó celular'),
        _Dato('Usa la app', usaLaApp(ficha.cuenta)),
        _Dato('Cliente desde', fechaLegible(ficha.afiliadoEn)),
        if (!ficha.datosCompletos) ...[
          const SizedBox(height: VeciEspacio.s),
          const Text(
            'Solo el dueño ve el documento y el celular completos.',
            style: TextStyle(color: VeciColores.tintaSuave),
          ),
        ],
      ],
    ),
  );
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: VeciEspacio.s),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(etiqueta, style: const TextStyle(color: VeciColores.tintaSuave)),
        Text(
          valor,
          style: const TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
        ),
      ],
    ),
  );
}
