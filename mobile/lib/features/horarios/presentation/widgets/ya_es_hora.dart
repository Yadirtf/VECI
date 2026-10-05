import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/horario.dart';
import '../../domain/reglas/ya_es_hora.dart';
import 'arco_del_sol.dart';
import 'frase_del_momento.dart';

/// "¿Ya es hora?": la respuesta grande arriba, el camino del sol de hoy debajo.
/// Se repinta cada minuto con el reloj del celular; no necesita internet.
class YaEsHora extends StatefulWidget {
  const YaEsHora({super.key, required this.horarios, required this.reloj});

  final List<Horario> horarios;
  final DateTime Function() reloj;

  @override
  State<YaEsHora> createState() => _YaEsHoraState();
}

class _YaEsHoraState extends State<YaEsHora> {
  late final Timer _minutero;

  @override
  void initState() {
    super.initState();
    _minutero = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _minutero.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ahora = widget.reloj();
    final horarios = widget.horarios;
    final momento = momentoDelServicio(horarios, ahora);
    final (frase, detalle) = fraseDelMomento(momento);
    final abierto = momento is EnServicio;
    return Container(
      padding: const EdgeInsets.fromLTRB(VeciEspacio.l, VeciEspacio.l, VeciEspacio.l, 0),
      decoration: BoxDecoration(
        color: abierto ? VeciColores.selvaClaro : VeciColores.arcilla.withValues(alpha: 0.08),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(VeciRadio.l * 2),
          topRight: Radius.circular(VeciRadio.l),
          bottomLeft: Radius.circular(VeciRadio.l),
          bottomRight: Radius.circular(VeciRadio.l * 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            frase,
            style: const TextStyle(
              fontSize: VeciTexto.grande,
              fontWeight: VeciPeso.fuerte,
              color: VeciColores.selvaOscuro,
              height: 1.1,
            ),
          ),
          const SizedBox(height: VeciEspacio.s),
          Text(
            detalle,
            style: const TextStyle(fontSize: VeciTexto.cuerpo, color: VeciColores.tinta),
          ),
          ArcoDelSol(
            horarios: horariosDelDia(horarios, ahora),
            ahora: ahora,
            etiqueta: '$frase. $detalle',
          ),
        ],
      ),
    );
  }
}
