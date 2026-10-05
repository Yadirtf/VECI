import 'package:drift/drift.dart' show Value;
import 'package:veci_api/api.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/cliente_en_caja.dart';
import '../../domain/entities/ficha_cliente.dart';
import '../../domain/entities/lectura_qr.dart';
import '../../domain/entities/registro_asistido.dart';

/// Traducciones entre el API, la base local y las entidades del dominio.
abstract final class ClienteModel {
  static CuentaCliente cuenta(String codigo) => switch (codigo) {
    'ACTIVA' => CuentaCliente.activa,
    'PENDIENTE' => CuentaCliente.pendiente,
    _ => CuentaCliente.sinCuenta,
  };

  static String codigoDeCuenta(CuentaCliente cuenta) => switch (cuenta) {
    CuentaCliente.activa => 'ACTIVA',
    CuentaCliente.pendiente => 'PENDIENTE',
    CuentaCliente.sinCuenta => 'SIN_CUENTA',
  };

  static ClienteEnCaja desdeCopia(ClienteEnCajaResponse r) => ClienteEnCaja(
    clienteId: r.clienteId,
    nombre: r.nombre,
    nombreBusqueda: r.nombreBusqueda,
    documento: r.documento,
    documentoFinal: r.documentoFinal,
    celular: r.celular,
    celularFinal: r.celularFinal,
    cuenta: cuenta(r.cuenta.toJson()),
    estado: r.estado.toJson(),
  );

  static ClienteEnCaja desdeFila(ClienteEnCajaLocal f) => ClienteEnCaja(
    clienteId: f.clienteId,
    nombre: f.nombre,
    nombreBusqueda: f.nombreBusqueda,
    documento: f.documento,
    documentoFinal: f.documentoFinal,
    celular: f.celular,
    celularFinal: f.celularFinal,
    cuenta: cuenta(f.cuenta),
    estado: f.estado,
  );

  static ClientesEnCajaCompanion aFila(String comercioId, ClienteEnCaja c) =>
      ClientesEnCajaCompanion.insert(
        comercioId: comercioId,
        clienteId: c.clienteId,
        nombre: c.nombre,
        nombreBusqueda: c.nombreBusqueda,
        documento: c.documento,
        documentoFinal: c.documentoFinal,
        celular: Value(c.celular),
        celularFinal: Value(c.celularFinal),
        cuenta: codigoDeCuenta(c.cuenta),
        estado: c.estado,
      );

  static FichaCliente ficha(ClienteResponse r) => FichaCliente(
    clienteId: r.clienteId,
    nombre: r.nombre,
    tipoDocumento: r.tipoDocumento,
    documento: r.documento,
    celular: r.celular,
    cuenta: cuenta(r.cuenta.toJson()),
    estado: r.estado.toJson(),
    afiliadoEn: r.afiliadoEn,
    datosCompletos: r.datosCompletos,
  );

  static PersonaEncontrada persona(PersonaPorAfiliarResponse r) => PersonaEncontrada(
    personaId: r.personaId,
    nombre: r.nombre,
    documento: r.documento,
    clienteId: r.clienteId,
  );

  /// Cada resultado de POST /clientes/qr en su caso del dominio.
  static LecturaQr lectura(LecturaQrResponse r) {
    final persona = r.persona;
    final cliente = r.cliente;
    return switch (r.resultado) {
      LecturaQrResponseResultadoEnum.PERSONA_POR_AFILIAR when persona != null => PorAfiliar(
        ClienteModel.persona(persona),
      ),
      LecturaQrResponseResultadoEnum.CLIENTE when cliente != null => YaEsCliente(ficha(cliente)),
      LecturaQrResponseResultadoEnum.QR_CAMBIADO => const QrCambiado(),
      LecturaQrResponseResultadoEnum.OTRO_NEGOCIO => const QrDeOtroNegocio(),
      _ => const QrAjeno(),
    };
  }

  static TipoDocumento tipo(TipoDocumentoResponse r) =>
      TipoDocumento(codigo: r.codigo, nombre: r.nombre, patron: r.patron);

  static PoliticaEnCorto politica(PoliticaResponse r) => PoliticaEnCorto(
    id: r.id,
    version: r.version,
    anotamos: r.enCorto.anotamos,
    nuncaHacemos: r.enCorto.nuncaHacemos,
    paraQue: r.enCorto.paraQue,
  );

  static RegistroAsistidoRequest pedido(DatosRegistroAsistido d) => RegistroAsistidoRequest(
    tipoDocumento: d.tipoDocumento,
    numeroDocumento: d.numeroDocumento,
    politicaVersionId: d.politicaVersionId,
    nombres: d.nombres,
    apellidos: d.apellidos,
    celular: d.celular,
    celularCompartido: d.celularCompartido,
  );
}
