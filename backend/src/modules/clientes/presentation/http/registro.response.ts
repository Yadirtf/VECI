import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class EnCortoResponse {
  @ApiProperty({ example: ['Tu nombre', 'Tu celular', 'Tu documento'], type: [String] })
  anotamos!: string[];

  @ApiProperty({ example: ['Vender ni prestar tus datos'], type: [String] })
  nuncaHacemos!: string[];

  @ApiProperty({ example: 'Para saber cuántos almuerzos te quedan.' })
  paraQue!: string;
}

export class SeccionPoliticaResponse {
  @ApiProperty({ example: 'Quién ve tus datos' })
  titulo!: string;

  @ApiProperty({ example: 'La cajera ve tu nombre y los últimos 4 números de tu documento.' })
  enPalabrasDeVecino!: string;

  @ApiProperty()
  texto!: string;
}

export class PoliticaResponse {
  @ApiProperty({ format: 'uuid', description: 'Se envía al aceptar' })
  id!: string;

  @ApiProperty({ example: '1.0' })
  version!: string;

  @ApiProperty({ format: 'date-time' })
  publicadaEn!: Date;

  @ApiProperty({ description: 'SHA-256 del contenido, en hexadecimal' })
  huella!: string;

  @ApiProperty({ type: EnCortoResponse })
  enCorto!: EnCortoResponse;

  @ApiProperty({ type: SeccionPoliticaResponse, isArray: true })
  secciones!: SeccionPoliticaResponse[];
}

export class TipoDocumentoResponse {
  @ApiProperty({ example: 'CC' })
  codigo!: string;

  @ApiProperty({ example: 'Cédula de ciudadanía' })
  nombre!: string;

  @ApiPropertyOptional({ example: '^[0-9]{6,10}$', nullable: true, type: String })
  patron!: string | null;
}

export class MiQrResponse {
  @ApiProperty({ description: 'Texto del QR: solo un token firmado, sin datos personales' })
  token!: string;

  @ApiProperty({ example: 1 })
  version!: number;

  @ApiProperty({ format: 'date-time' })
  emitidoEn!: Date;
}

export class QrEnComercioResponse {
  @ApiProperty({ description: 'Token firmado por el negocio' })
  token!: string;

  @ApiProperty({ example: 1 })
  version!: number;
}

export class MiComercioResponse {
  @ApiProperty({ format: 'uuid' })
  comercioId!: string;

  @ApiProperty({ example: 'Restaurante La Vecina' })
  nombre!: string;

  @ApiProperty({ example: 'RESTAURANT' })
  tipoNegocio!: string;

  @ApiProperty({ format: 'date-time' })
  afiliadoEn!: Date;

  @ApiPropertyOptional({ type: QrEnComercioResponse, nullable: true })
  qr!: QrEnComercioResponse | null;
}
