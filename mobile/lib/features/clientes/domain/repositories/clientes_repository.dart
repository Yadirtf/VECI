import '../entities/cliente_en_caja.dart';
import '../entities/ficha_cliente.dart';
import '../entities/lectura_qr.dart';
import '../entities/registro_asistido.dart';

/// Clientes del negocio activo desde la caja (EP-04). La copia local sirve sin
/// internet; afiliar y registrar necesitan señal (la cola llega en EP-07).
abstract interface class ClientesRepository {
  /// La copia guardada en el celular, sin ir al servidor.
  Future<CopiaDeClientes> copiaGuardada();

  /// Pregunta al servidor si la copia cambió (ETag) y la reemplaza si hace falta.
  /// Sin señal devuelve la guardada con [CopiaDeClientes.sinSenal].
  Future<CopiaDeClientes> actualizarCopia();

  Future<LecturaQr> leerQr(String token);

  /// Afilia a la persona del QR; devuelve su ficha y si ya estaba.
  Future<(FichaCliente, bool)> afiliar(String token);

  Future<FichaCliente> ficha(String clienteId);

  Future<String> darPinDeBienvenida(String clienteId);

  Future<List<TipoDocumento>> tiposDeDocumento();

  Future<PoliticaEnCorto> politica();

  /// Busca a la persona por documento en todo VECI; null si no está.
  Future<PersonaEncontrada?> revisarDocumento(String tipoDocumento, String numero);

  Future<RegistroHecho> registrar(DatosRegistroAsistido datos);
}
