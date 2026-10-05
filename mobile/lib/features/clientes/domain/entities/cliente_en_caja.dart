/// Si el cliente usa la app: activa, pendiente (lo anotaron y no ha entrado) o sin
/// cuenta propia (registrado con un celular compartido).
enum CuentaCliente { activa, pendiente, sinCuenta }

/// Un cliente en la copia local de la caja (HU-04-05). Solo trae lo que la caja puede
/// ver: el documento y el celular enmascarados y sus últimos 4 números.
class ClienteEnCaja {
  const ClienteEnCaja({
    required this.clienteId,
    required this.nombre,
    required this.nombreBusqueda,
    required this.documento,
    required this.documentoFinal,
    required this.cuenta,
    required this.estado,
    this.celular,
    this.celularFinal,
  });

  final String clienteId;

  /// "Luz Marina Castro".
  final String nombre;

  /// El nombre en minúsculas y sin tildes: "luz marina castro".
  final String nombreBusqueda;

  /// "****5678".
  final String documento;

  /// "5678".
  final String documentoFinal;

  /// "••• 8888" o null si no dejó celular.
  final String? celular;
  final String? celularFinal;
  final CuentaCliente cuenta;

  /// ACTIVE, BLOCKED o ENDED.
  final String estado;
}

/// La copia de clientes guardada en el celular y desde cuándo está al día.
class CopiaDeClientes {
  const CopiaDeClientes({required this.clientes, this.alDiaEn, this.sinSenal = false});

  static const vacia = CopiaDeClientes(clientes: []);

  final List<ClienteEnCaja> clientes;

  /// Última vez que el servidor confirmó la copia (con 200 o con 304); null si nunca.
  final DateTime? alDiaEn;

  /// true si la última revisión no pudo hablar con el servidor.
  final bool sinSenal;
}
