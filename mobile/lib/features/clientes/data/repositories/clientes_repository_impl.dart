import '../../../../core/error/fallo.dart';
import '../../../../core/observabilidad/vigilante_sincronizacion.dart';
import '../../domain/entities/cliente_en_caja.dart';
import '../../domain/entities/ficha_cliente.dart';
import '../../domain/entities/lectura_qr.dart';
import '../../domain/entities/registro_asistido.dart';
import '../../domain/repositories/clientes_repository.dart';
import '../datasources/clientes_local_datasource.dart';
import '../datasources/clientes_remote_datasource.dart';

/// Clientes del negocio activo. La búsqueda usa la copia del celular (sirve sin
/// internet); la copia se baja con ETag y solo cambia si el servidor manda otra.
/// Afiliar, registrar y ver la ficha van al servidor: necesitan señal en EP-04.
class ClientesRepositoryImpl implements ClientesRepository {
  ClientesRepositoryImpl(
    this._remoto,
    this._local,
    this._comercioId, {
    DateTime Function()? reloj,
    this._vigilante,
  }) : _reloj = reloj ?? DateTime.now;

  final ClientesRemoteDatasource _remoto;
  final ClientesLocalDatasource _local;
  final String _comercioId;
  final DateTime Function() _reloj;
  final VigilanteSincronizacion? _vigilante;

  @override
  Future<CopiaDeClientes> copiaGuardada({bool sinSenal = false}) async {
    final marca = await _local.marca(_comercioId);
    if (marca == null) return CopiaDeClientes(clientes: const [], sinSenal: sinSenal);
    return CopiaDeClientes(
      clientes: await _local.leer(_comercioId),
      alDiaEn: marca.alDiaEn,
      sinSenal: sinSenal,
    );
  }

  @override
  Future<CopiaDeClientes> actualizarCopia() async {
    try {
      final marca = await _local.marca(_comercioId);
      final respuesta = await _remoto.bajarCopia(etag: marca?.etag);
      _vigilante?.registrarExito();
      final ahora = _reloj();
      final clientes = respuesta.clientes;
      if (respuesta.sinCambios || clientes == null) {
        await _local.confirmar(_comercioId, ahora);
      } else {
        await _local.reemplazar(
          _comercioId,
          clientes,
          version: respuesta.version ?? '',
          etag: respuesta.etag,
          ahora: ahora,
        );
      }
      return await copiaGuardada();
    } on SinConexion {
      return copiaGuardada(sinSenal: true);
    } on ServidorNoDisponible catch (fallo) {
      _vigilante?.registrarFallo(fallo);
      return copiaGuardada(sinSenal: true);
    }
  }

  @override
  Future<LecturaQr> leerQr(String token) => _remoto.leerQr(token);

  @override
  Future<(FichaCliente, bool)> afiliar(String token) => _remoto.afiliar(token);

  @override
  Future<FichaCliente> ficha(String clienteId) => _remoto.ficha(clienteId);

  @override
  Future<String> darPinDeBienvenida(String clienteId) => _remoto.darPinDeBienvenida(clienteId);

  @override
  Future<List<TipoDocumento>> tiposDeDocumento() => _remoto.tiposDeDocumento();

  @override
  Future<PoliticaEnCorto> politica() => _remoto.politica();

  @override
  Future<PersonaEncontrada?> revisarDocumento(String tipoDocumento, String numero) =>
      _remoto.revisarDocumento(tipoDocumento, numero);

  @override
  Future<RegistroHecho> registrar(DatosRegistroAsistido datos) => _remoto.registrar(datos);
}
