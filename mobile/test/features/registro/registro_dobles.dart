import 'package:veci/core/error/fallo.dart';
import 'package:veci/features/registro/domain/entities/registro.dart';
import 'package:veci/features/registro/domain/repositories/registro_repository.dart';

const politicaDePrueba = PoliticaDeDatos(
  id: 'pol-1',
  version: '1.0',
  anotamos: ['Tu nombre y tu documento'],
  nuncaHacemos: ['Vender tus datos'],
  paraQue: 'Para que el negocio te reconozca.',
  secciones: [
    SeccionPolitica(
      titulo: 'Quién cuida tus datos',
      enPalabrasDeVecino: 'VECI los guarda y responde por ellos.',
      texto: 'El responsable del tratamiento es VECI S.A.S.',
    ),
  ],
);

/// Registro de mentiras: guarda lo enviado y responde lo que diga la prueba.
class RegistroFalso implements RegistroRepository {
  BorradorRegistro? enviado;
  String? politicaAceptada;
  Fallo? fallo;

  @override
  Future<List<TipoDocumento>> tiposDeDocumento() async => const [
    TipoDocumento(codigo: 'CC', nombre: 'Cédula', patron: r'^[0-9]{6,10}$'),
    TipoDocumento(codigo: 'PASSPORT', nombre: 'Pasaporte'),
  ];

  @override
  Future<PoliticaDeDatos> politica() async => politicaDePrueba;

  @override
  Future<void> registrarme(BorradorRegistro borrador, String politicaVersionId) async {
    if (fallo != null) throw fallo!;
    enviado = borrador;
    politicaAceptada = politicaVersionId;
  }
}
