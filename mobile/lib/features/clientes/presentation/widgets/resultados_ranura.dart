import 'package:flutter/material.dart';

import '../../../../core/theme/veci_tokens.dart';
import '../../../../core/ui/veci_aviso.dart';
import '../../../../core/ui/veci_boton.dart';
import '../../../../core/ui/veci_tarjeta.dart';
import '../../domain/entities/cliente_en_caja.dart';
import '../../domain/reglas/consulta_caja.dart';
import 'fechas.dart';

/// Lo que se ve encima de la ranura: una ayuda, los clientes que coinciden o
/// "Registrar a …", y al pie desde cuándo está al día la copia del celular.
class ResultadosRanura extends StatelessWidget {
  const ResultadosRanura({
    super.key,
    required this.copia,
    required this.consulta,
    required this.ahora,
    required this.alAbrir,
    required this.alRegistrar,
  });

  final CopiaDeClientes copia;
  final ConsultaCaja consulta;
  final DateTime ahora;
  final ValueChanged<ClienteEnCaja> alAbrir;
  final VoidCallback alRegistrar;

  @override
  Widget build(BuildContext context) {
    final encontrados = buscarEnCopia(copia.clientes, consulta);
    return ListView(
      padding: const EdgeInsets.fromLTRB(VeciEspacio.m, VeciEspacio.l, VeciEspacio.m, 0),
      children: [
        if (copia.sinSenal && copia.alDiaEn == null) ...[
          const VeciAviso(
            tono: TonoAviso.aviso,
            mensaje: 'Aún no tienes la copia de tus clientes. Conéctate una vez, veci.',
          ),
          const SizedBox(height: VeciEspacio.m),
        ],
        if (!consulta.alcanza)
          const _Ayuda()
        else ...[
          for (final cliente in encontrados) _FilaCliente(cliente, alTocar: () => alAbrir(cliente)),
          if (encontrados.isEmpty)
            Text(
              'No encontramos a "${consulta.texto}" en tus clientes.',
              style: const TextStyle(fontSize: VeciTexto.cuerpo),
            ),
          const SizedBox(height: VeciEspacio.m),
          VeciBoton(
            texto: 'Registrar a ${consulta.texto}',
            icono: Icons.person_add_alt_1,
            secundario: encontrados.isNotEmpty,
            alTocar: alRegistrar,
          ),
        ],
        const SizedBox(height: VeciEspacio.l),
        _Pie(copia: copia, ahora: ahora),
      ],
    );
  }
}

class _Ayuda extends StatelessWidget {
  const _Ayuda();

  @override
  Widget build(BuildContext context) => const VeciTarjeta(
    child: Text(
      'Escribe 3 letras de su nombre, su celular o los últimos 4 números de su documento. '
      'O escanea su QR.',
      style: TextStyle(fontSize: VeciTexto.cuerpo),
    ),
  );
}

class _FilaCliente extends StatelessWidget {
  const _FilaCliente(this.cliente, {required this.alTocar});

  final ClienteEnCaja cliente;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final celular = cliente.celular;
    final detalle = celular == null
        ? 'Doc. ${cliente.documento}'
        : 'Doc. ${cliente.documento} · Cel. $celular';
    return Card(
      margin: const EdgeInsets.only(bottom: VeciEspacio.s),
      child: ListTile(
        minTileHeight: VeciToque.boton,
        title: Text(
          cliente.nombre,
          style: const TextStyle(fontSize: VeciTexto.subtitulo, fontWeight: VeciPeso.medio),
        ),
        subtitle: Text(detalle),
        trailing: cliente.cuenta == CuentaCliente.activa
            ? const Icon(Icons.chevron_right)
            : const Text('Sin app aún', style: TextStyle(color: VeciColores.tintaSuave)),
        onTap: alTocar,
      ),
    );
  }
}

class _Pie extends StatelessWidget {
  const _Pie({required this.copia, required this.ahora});

  final CopiaDeClientes copia;
  final DateTime ahora;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: VeciEspacio.m),
    child: Text(
      [
        copiaAlDia(copia.alDiaEn, ahora),
        if (copia.sinSenal && copia.alDiaEn != null) 'Sin señal: buscas en la copia del celular.',
      ].join('\n'),
      textAlign: TextAlign.center,
      style: const TextStyle(color: VeciColores.tintaSuave),
    ),
  );
}
