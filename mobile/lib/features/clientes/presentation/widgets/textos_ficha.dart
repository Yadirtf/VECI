import '../../domain/entities/cliente_en_caja.dart';

/// Nombre del tipo de documento para la pantalla.
String nombreDelDocumento(String codigo) => switch (codigo) {
  'CC' => 'Cédula',
  'TI' => 'Tarjeta de identidad',
  'RC' => 'Registro civil',
  'CE' => 'Cédula de extranjería',
  'PPT' => 'Permiso de protección temporal',
  'PASSPORT' => 'Pasaporte',
  _ => 'Documento',
};

/// Si usa la app, dicho para el cajero.
String usaLaApp(CuentaCliente cuenta) => switch (cuenta) {
  CuentaCliente.activa => 'Sí, ya usa su app',
  CuentaCliente.pendiente => 'Aún no activa su app',
  CuentaCliente.sinCuenta => 'No: su celular es compartido',
};
