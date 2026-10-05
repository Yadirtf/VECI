import '../../../../core/error/fallo.dart';
import '../../../../core/observabilidad/vigilante_sincronizacion.dart';
import '../../domain/repositories/horarios_repository.dart';
import '../datasources/horarios_local_datasource.dart';
import '../datasources/horarios_remote_datasource.dart';

/// Primero el API; si no hay internet, lo último guardado en el celular (sección 5.3.4).
/// Con la ETag guardada el servidor responde 304 cuando nada cambió y no se baja otra vez.
/// El resto de la app no sabe si hubo conexión: solo recibe el resultado.
/// Quedarse sin señal es normal; que el servidor falle una y otra vez se avisa (HU-01-07).
class HorariosRepositoryImpl implements HorariosRepository {
  HorariosRepositoryImpl(this._remoto, this._local, {DateTime Function()? reloj, this._vigilante})
    : _reloj = reloj ?? DateTime.now;

  final HorariosRemoteDatasource _remoto;
  final HorariosLocalDatasource _local;
  final DateTime Function() _reloj;
  final VigilanteSincronizacion? _vigilante;

  @override
  Future<ResultadoHorarios> obtener() async {
    try {
      final guardados = await _local.leer();
      // Sin copia local se piden completos aunque haya una marca vieja.
      final respuesta = await _remoto.listar(etag: guardados.isEmpty ? null : await _local.etag());
      _vigilante?.registrarExito();
      if (respuesta.sinCambios) return ResultadoHorarios(horarios: guardados, desdeCelular: false);
      final horarios = respuesta.horarios!;
      await _local.reemplazar(horarios, _reloj(), etag: respuesta.etag);
      return ResultadoHorarios(horarios: horarios, desdeCelular: false);
    } on SinConexion {
      return _desdeCelular(const SinConexion());
    } on ServidorNoDisponible catch (fallo) {
      _vigilante?.registrarFallo(fallo);
      return _desdeCelular(fallo);
    }
  }

  Future<ResultadoHorarios> _desdeCelular(Fallo fallo) async {
    final guardados = await _local.leer();
    if (guardados.isEmpty) throw fallo;
    return ResultadoHorarios(horarios: guardados, desdeCelular: true);
  }
}
