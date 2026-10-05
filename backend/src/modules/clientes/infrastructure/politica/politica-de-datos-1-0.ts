import { ContenidoPolitica } from '../../application/puertos/politica.repository';

/**
 * Política de tratamiento de datos, versión 1.0 (HU-12-01, Ley 1581 de 2012).
 * Cada sección trae el texto legal y su explicación "en palabras de vecino".
 * La huella SHA-256 de este contenido está en compliance.policy_versions: si se
 * cambia una coma, la prueba de integridad falla y hay que publicar otra versión.
 * Antes de producción la revisa un abogado (ver docs/legal/README.md).
 */
export const POLITICA_1_0: ContenidoPolitica = {
  version: '1.0',
  enCorto: {
    anotamos: ['Tu nombre', 'Tu celular', 'Tu documento'],
    nuncaHacemos: [
      'Vender ni prestar tus datos',
      'Mostrar tu documento completo a la cajera',
      'Contarle a un negocio en qué otros negocios estás',
    ],
    paraQue: 'Para saber cuántos almuerzos te quedan en cada negocio y avisarte cuando comes.',
  },
  secciones: [
    {
      titulo: 'Quién cuida tus datos',
      enPalabrasDeVecino:
        'VECI guarda tus datos. Cada negocio donde tienes tiquetera usa solo lo tuyo con él.',
      texto:
        'VECI es responsable del tratamiento de los datos personales que se recogen en la ' +
        'aplicación, en el panel web y en la caja de los negocios aliados. Cada negocio aliado ' +
        'actúa como encargado y solo trata los datos de las personas afiliadas a él.',
    },
    {
      titulo: 'Qué datos recogemos',
      enPalabrasDeVecino: 'Solo tu nombre, tu celular y tu documento. Nada más.',
      texto:
        'Recogemos nombres y apellidos, número de celular, tipo y número de documento de ' +
        'identidad, y el registro de las compras y consumos de tiqueteras. No recogemos datos ' +
        'sensibles, ni ubicación, ni contactos del celular.',
    },
    {
      titulo: 'Para qué los usamos',
      enPalabrasDeVecino: 'Para llevar tu tiquetera y que nadie más la use.',
      texto:
        'Los datos se usan para identificarte en los negocios donde estás afiliado, llevar el ' +
        'saldo de tus tiqueteras, registrar cada compra y consumo, avisarte de ellos y prevenir ' +
        'fraudes. No se usan para publicidad de terceros.',
    },
    {
      titulo: 'Quién los ve',
      enPalabrasDeVecino:
        'La cajera ve tu nombre y los últimos 4 números de tu documento. Solo el dueño lo ve completo.',
      texto:
        'Cada negocio ve únicamente los datos de sus propios clientes. El personal de caja ve el ' +
        'documento y el celular enmascarados; el propietario del negocio puede verlos completos. ' +
        'Ningún negocio puede saber en qué otros negocios está afiliada una persona. VECI no ' +
        'vende ni cede datos personales.',
    },
    {
      titulo: 'Tus derechos',
      enPalabrasDeVecino: 'Puedes pedir ver, corregir o borrar tus datos cuando quieras.',
      texto:
        'Como titular puedes conocer, actualizar y rectificar tus datos, pedir prueba de esta ' +
        'autorización, saber qué uso se les ha dado, revocar la autorización, pedir su ' +
        'supresión y presentar quejas ante la Superintendencia de Industria y Comercio. Las ' +
        'consultas se responden en máximo 10 días hábiles y los reclamos en máximo 15.',
    },
    {
      titulo: 'Cómo los protegemos',
      enPalabrasDeVecino: 'Tu PIN va cifrado y tu QR no lleva tus datos.',
      texto:
        'El PIN se guarda cifrado y nadie puede leerlo. Los códigos QR llevan solo una firma ' +
        'digital, sin nombre, documento ni saldo. El acceso de cada negocio está aislado del de ' +
        'los demás y cada acción sensible queda registrada en una bitácora.',
    },
    {
      titulo: 'Cuánto tiempo los guardamos',
      enPalabrasDeVecino:
        'Mientras uses VECI. Si pides borrarlos, quitamos tus datos y solo queda la cuenta del negocio.',
      texto:
        'Los datos se conservan mientras exista una relación con algún negocio aliado. Si pides ' +
        'la supresión, tus datos personales se eliminan; los registros contables de compras y ' +
        'consumos se conservan sin datos que te identifiquen, porque el negocio está obligado a ' +
        'guardarlos.',
    },
    {
      titulo: 'Menores de edad',
      enPalabrasDeVecino: 'Si eres menor de edad, un adulto responsable acepta por ti.',
      texto:
        'Los datos de niños, niñas y adolescentes solo se tratan con la autorización de su ' +
        'representante legal y respetando su interés superior.',
    },
  ],
};
