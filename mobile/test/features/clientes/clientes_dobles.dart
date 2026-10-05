import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/clientes/domain/entities/cliente_en_caja.dart';
import 'package:veci/features/clientes/domain/entities/ficha_cliente.dart';
import 'package:veci/features/clientes/domain/entities/lectura_qr.dart';
import 'package:veci/features/clientes/domain/entities/registro_asistido.dart';
import 'package:veci/features/clientes/domain/repositories/clientes_repository.dart';

ClienteEnCaja clienteDePrueba({
  String id = 'c1',
  String nombre = 'Luz Marina Castro',
  String busqueda = 'luz marina castro',
  String documentoFinal = '5678',
  String? celularFinal = '8888',
  CuentaCliente cuenta = CuentaCliente.activa,
}) => ClienteEnCaja(
  clienteId: id,
  nombre: nombre,
  nombreBusqueda: busqueda,
  documento: '****$documentoFinal',
  documentoFinal: documentoFinal,
  celular: celularFinal == null ? null : '••• $celularFinal',
  celularFinal: celularFinal,
  cuenta: cuenta,
  estado: 'ACTIVE',
);

FichaCliente fichaDePrueba({String id = 'c1', CuentaCliente cuenta = CuentaCliente.activa}) =>
    FichaCliente(
      clienteId: id,
      nombre: 'Luz Marina Castro',
      tipoDocumento: 'CC',
      documento: '****5678',
      celular: '••• 8888',
      cuenta: cuenta,
      estado: 'ACTIVE',
      afiliadoEn: DateTime(2026, 10, 3, 9),
    );

const personaDePrueba = PersonaEncontrada(
  personaId: 'p1',
  nombre: 'Luz Marina C.',
  documento: '****5678',
);

const politicaDePrueba = PoliticaEnCorto(
  id: 'pol-1',
  version: '1.0',
  anotamos: ['Tu nombre y tu celular'],
  nuncaHacemos: ['Vender tus datos'],
  paraQue: 'Para que tu negocio sepa quién eres.',
);

const tiposDePrueba = [
  TipoDocumento(codigo: 'CC', nombre: 'Cédula de ciudadanía', patron: r'^[0-9]{6,10}$'),
  TipoDocumento(codigo: 'TI', nombre: 'Tarjeta de identidad'),
];

/// Repositorio en memoria: cada respuesta se fija desde la prueba.
class RepositorioClientesFalso implements ClientesRepository {
  CopiaDeClientes copia = CopiaDeClientes(
    clientes: [clienteDePrueba()],
    alDiaEn: DateTime(2026, 10, 5, 10, 42),
  );
  LecturaQr lectura = const PorAfiliar(personaDePrueba);
  Object? fallo;
  PersonaEncontrada? revision;
  final registros = <DatosRegistroAsistido>[];
  final afiliados = <String>[];
  var actualizaciones = 0;

  /// Respuestas en orden para registrar(); un [Fallo] se lanza.
  final respuestasRegistro = <Object>[];

  Future<T> _o<T>(T valor) async {
    final error = fallo;
    if (error != null) throw error;
    return valor;
  }

  @override
  Future<CopiaDeClientes> copiaGuardada() async => copia;

  @override
  Future<CopiaDeClientes> actualizarCopia() async {
    actualizaciones++;
    return copia;
  }

  @override
  Future<LecturaQr> leerQr(String token) => _o(lectura);

  @override
  Future<(FichaCliente, bool)> afiliar(String token) {
    afiliados.add(token);
    return _o((fichaDePrueba(), false));
  }

  @override
  Future<FichaCliente> ficha(String clienteId) =>
      _o(fichaDePrueba(id: clienteId, cuenta: CuentaCliente.pendiente));

  @override
  Future<String> darPinDeBienvenida(String clienteId) => _o('482915');

  @override
  Future<List<TipoDocumento>> tiposDeDocumento() => _o(tiposDePrueba);

  @override
  Future<PoliticaEnCorto> politica() => _o(politicaDePrueba);

  @override
  Future<PersonaEncontrada?> revisarDocumento(String tipoDocumento, String numero) => _o(revision);

  @override
  Future<RegistroHecho> registrar(DatosRegistroAsistido datos) async {
    registros.add(datos);
    final respuesta = respuestasRegistro.isEmpty
        ? RegistroHecho(ficha: fichaDePrueba(), vinculado: false, pinBienvenida: '482915')
        : respuestasRegistro.removeAt(0);
    if (respuesta is Fallo) throw respuesta;
    return respuesta as RegistroHecho;
  }
}
