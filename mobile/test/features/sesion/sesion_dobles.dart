import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/sesion/domain/entities/sesion.dart';
import 'package:veci/features/sesion/domain/repositories/sesion_repository.dart';

const negocio = Espacio(
  comercioId: 'c1',
  nombre: 'Restaurante La Vecina',
  roles: ['CASHIER'],
  invitacionPendiente: false,
);

SesionAbierta sesionDePrueba(String token, {DateTime? venceEn, List<Espacio>? espacios}) =>
    SesionAbierta(
      tokenAcceso: token,
      tokenRenovacion: 'r-$token',
      venceEn: venceEn ?? DateTime(2030),
      nombre: 'Jhon',
      espacios: espacios ?? const [negocio],
    );

/// Servidor de mentiras: cuenta las llamadas y responde lo que diga la prueba.
class RepositorioFalso implements SesionRepository {
  ResultadoIngreso ingreso = IngresoConSesion(sesionDePrueba('t1'));
  SesionAbierta? renovada = sesionDePrueba('t2');
  bool sinSenal = false;
  int renovaciones = 0;
  final elegidos = <String>[];
  final salidas = <String>[];

  @override
  Future<ResultadoIngreso> entrarConPin(String celular, String pin) async => ingreso;

  @override
  Future<SesionAbierta> crearPinNuevo(String tokenCambio, String pinNuevo) async =>
      sesionDePrueba('t-nuevo');

  @override
  Future<SesionAbierta?> renovar(String tokenRenovacion) async {
    renovaciones++;
    if (sinSenal) throw const SinConexion();
    return renovada;
  }

  @override
  Future<void> elegirComercio(String tokenAcceso, String comercioId) async =>
      elegidos.add(comercioId);

  @override
  Future<void> salir(String tokenAcceso) async => salidas.add(tokenAcceso);
}

class AlmacenFalso implements AlmacenSesion {
  SesionAbierta? sesion;
  String? comercio;

  @override
  Future<SesionAbierta?> leerSesion() async => sesion;

  @override
  Future<void> guardarSesion(SesionAbierta? valor) async => sesion = valor;

  @override
  Future<String?> leerComercio() async => comercio;

  @override
  Future<void> guardarComercio(String? valor) async => comercio = valor;
}

class PendientesFalsos implements EventosPendientes {
  PendientesFalsos([this.cuantos = 0]);

  final int cuantos;

  @override
  Future<int> contar() async => cuantos;
}
