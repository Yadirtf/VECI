import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../domain/entities/estado_de_cuenta.dart';
import '../../domain/reglas/reglas_venta.dart';

const _enmiendas = {'SALE_VOID', 'ADJUSTMENT', 'CONSUMPTION_REVERSAL'};

/// La historia del saldo, del más reciente al más antiguo. Las correcciones van en
/// color arcilla: se ven, nunca se borran (HU-05-05).
class HistoriaSaldo extends StatelessWidget {
  const HistoriaSaldo({super.key, required this.movimientos});

  final List<Movimiento> movimientos;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Historia',
        style: TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.fuerte),
      ),
      for (final m in movimientos) _Renglon(m),
    ],
  );
}

class _Renglon extends StatelessWidget {
  const _Renglon(this.m);

  final Movimiento m;

  String get _detalle => [
    if (m.tiquetera != null) m.tiquetera!,
    if (m.motivo != null) m.motivo!,
    if (m.nota != null) '«${m.nota}»',
    m.quien ?? 'VECI',
    '${m.ocurridoEn.toLocal().day}/${m.ocurridoEn.toLocal().month}',
  ].join(' · ');

  @override
  Widget build(BuildContext context) {
    final color = _enmiendas.contains(m.tipo) ? VeciColores.arcillaOscuro : VeciColores.tinta;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      textColor: color,
      title: Text(textoMovimiento[m.tipo] ?? m.tipo),
      subtitle: Text(_detalle),
      trailing: Text(
        m.unidades > 0 ? '+${m.unidades}' : '${m.unidades}',
        style: const TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.fuerte),
      ),
    );
  }
}
