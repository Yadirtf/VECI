import '../../domain/entities/estado_de_cuenta.dart';
import '../../domain/repositories/ventas_repository.dart';
import '../datasources/copia_mis_tiqueteras.dart';
import '../datasources/ventas_remote_datasource.dart';
import '../models/tiqueteras_model.dart';

/// El saldo de la persona en sus negocios: lo del servidor y, sin señal, la copia.
class MisTiqueterasRepositoryImpl implements MisTiqueterasRepository {
  MisTiqueterasRepositoryImpl(this._remoto, this._copia);

  final VentasRemoteDatasource _remoto;
  final CopiaMisTiqueteras _copia;

  @override
  Future<List<SaldoEnNegocio>?> guardadas() async =>
      (await _copia.leer())?.map(TiqueterasModel.enNegocio).toList();

  @override
  Future<List<SaldoEnNegocio>> traer() async {
    final saldos = await _remoto.misTiqueteras();
    await _copia.guardar(saldos);
    return saldos.map(TiqueterasModel.enNegocio).toList();
  }

  @override
  Future<void> olvidar() => _copia.olvidar();
}
