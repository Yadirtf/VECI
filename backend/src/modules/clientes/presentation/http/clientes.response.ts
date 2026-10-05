import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

const CUENTAS = ['ACTIVA', 'PENDIENTE', 'SIN_CUENTA'];
const ESTADOS = ['ACTIVE', 'BLOCKED', 'ENDED'];

export class ClienteResponse {
  @ApiProperty({ format: 'uuid', description: 'Id de la afiliación: el cliente en este negocio' })
  clienteId!: string;

  @ApiProperty({ format: 'uuid' })
  personaId!: string;

  @ApiProperty({ example: 'Luz Marina Chindoy' })
  nombre!: string;

  @ApiProperty({ example: 'Luz Marina' })
  nombres!: string;

  @ApiPropertyOptional({ example: 'Chindoy', nullable: true, type: String })
  apellidos!: string | null;

  @ApiProperty({ example: 'CC' })
  tipoDocumento!: string;

  @ApiProperty({
    example: '****5678',
    description: 'Completo solo con customers.view_full_document',
  })
  documento!: string;

  @ApiPropertyOptional({ example: '••• 8888', nullable: true, type: String })
  celular!: string | null;

  @ApiProperty({ description: 'Se ven el documento y el celular completos' })
  datosCompletos!: boolean;

  @ApiProperty({ enum: CUENTAS, description: 'ACTIVA: usa la app. PENDIENTE: espera su PIN.' })
  cuenta!: string;

  @ApiProperty({ enum: ESTADOS })
  estado!: string;

  @ApiProperty({ enum: ['PERSONAL_QR_SCAN', 'ASSISTED_REGISTRATION', 'DATA_IMPORT'] })
  canal!: string;

  @ApiProperty({ format: 'date-time' })
  afiliadoEn!: Date;
}

export class PersonaPorAfiliarResponse {
  @ApiProperty({ format: 'uuid' })
  personaId!: string;

  @ApiProperty({ example: 'Luz Marina C.' })
  nombre!: string;

  @ApiProperty({ example: '****5678' })
  documento!: string;

  @ApiPropertyOptional({ format: 'uuid', nullable: true, type: String })
  clienteId!: string | null;
}

export class LecturaQrResponse {
  @ApiProperty({
    enum: ['PERSONA_POR_AFILIAR', 'CLIENTE', 'QR_CAMBIADO', 'OTRO_NEGOCIO', 'NO_ES_DE_VECI'],
  })
  resultado!: string;

  @ApiPropertyOptional({ type: PersonaPorAfiliarResponse })
  persona?: PersonaPorAfiliarResponse;

  @ApiPropertyOptional({ type: ClienteResponse })
  cliente?: ClienteResponse;
}

export class AfiliacionResponse {
  @ApiProperty({ description: 'Ya era cliente: no se creó nada' })
  yaEstaba!: boolean;

  @ApiProperty({ type: ClienteResponse })
  cliente!: ClienteResponse;
}

export class RevisionDocumentoResponse {
  @ApiPropertyOptional({ type: PersonaPorAfiliarResponse, nullable: true })
  persona!: PersonaPorAfiliarResponse | null;
}

export class RegistroAsistidoResponse {
  @ApiProperty({ description: 'Ya estaba en VECI y solo se afilió' })
  vinculado!: boolean;

  @ApiProperty({ type: ClienteResponse })
  cliente!: ClienteResponse;

  @ApiPropertyOptional({
    example: '482915',
    nullable: true,
    type: String,
    description: 'Se muestra una sola vez para dictárselo. Sirve 7 días.',
  })
  pinBienvenida!: string | null;
}

export class PinBienvenidaResponse {
  @ApiProperty({ example: '482915', description: 'Se muestra una sola vez. Sirve 7 días.' })
  pinBienvenida!: string;
}

export class ClienteEnCajaResponse {
  @ApiProperty({ format: 'uuid' })
  clienteId!: string;

  @ApiProperty({ example: 'Luz Marina Chindoy' })
  nombre!: string;

  @ApiProperty({ example: 'luz marina chindoy', description: 'Sin tildes ni mayúsculas' })
  nombreBusqueda!: string;

  @ApiProperty({ example: '****5678' })
  documento!: string;

  @ApiProperty({ example: '5678', description: 'Últimos 4 dígitos, para buscar sin internet' })
  documentoFinal!: string;

  @ApiPropertyOptional({ example: '••• 8888', nullable: true, type: String })
  celular!: string | null;

  @ApiPropertyOptional({ example: '8888', nullable: true, type: String })
  celularFinal!: string | null;

  @ApiProperty({ enum: CUENTAS })
  cuenta!: string;

  @ApiProperty({ enum: ESTADOS })
  estado!: string;
}

export class ClavePublicaResponse {
  @ApiProperty({ example: 'k1' })
  keyId!: string;

  @ApiProperty({ description: 'Ed25519, 32 bytes en base64url' })
  clavePublica!: string;
}

export class CopiaLocalResponse {
  @ApiProperty({ example: '1042.37', description: 'Va también en el ETag' })
  version!: string;

  @ApiProperty({ type: ClienteEnCajaResponse, isArray: true })
  clientes!: ClienteEnCajaResponse[];

  @ApiProperty({ type: ClavePublicaResponse, isArray: true })
  claves!: ClavePublicaResponse[];
}
