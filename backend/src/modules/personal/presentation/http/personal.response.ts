import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class MiembroResponse {
  @ApiProperty({ format: 'uuid' })
  membresiaId!: string;

  @ApiProperty({ format: 'uuid' })
  usuarioId!: string;

  @ApiProperty({ example: 'Jhon Mutumbajoy' })
  nombre!: string;

  @ApiPropertyOptional({ example: '+573100000102', nullable: true, type: String })
  celular!: string | null;

  @ApiProperty({ enum: ['INVITED', 'ACTIVE', 'SUSPENDED', 'REMOVED'] })
  estado!: string;

  @ApiProperty({ example: ['CASHIER'], type: [String] })
  roles!: readonly string[];
}

export class InvitacionResponse {
  @ApiProperty({ format: 'uuid' })
  membresiaId!: string;

  @ApiPropertyOptional({
    example: '482915',
    nullable: true,
    type: String,
    description: 'Se muestra una sola vez. null si la persona ya tenía PIN propio.',
  })
  pinTemporal!: string | null;
}

export class PinTemporalResponse {
  @ApiProperty({ example: '482915', description: 'Se muestra una sola vez' })
  pinTemporal!: string;
}

export class SesionEnDispositivoResponse {
  @ApiProperty({ format: 'uuid' })
  sesionId!: string;

  @ApiProperty({ format: 'uuid' })
  usuarioId!: string;

  @ApiProperty({ example: 'Jhon' })
  nombre!: string;

  @ApiProperty({ format: 'date-time' })
  abiertaDesde!: Date;

  @ApiProperty({ format: 'date-time' })
  ultimoUso!: Date;
}

export class DispositivoResponse {
  @ApiProperty({ format: 'uuid' })
  dispositivoId!: string;

  @ApiPropertyOptional({ example: 'Moto E13', nullable: true, type: String })
  nombre!: string | null;

  @ApiProperty({ example: 'ANDROID' })
  plataforma!: string;

  @ApiProperty({ format: 'date-time' })
  registradoEn!: Date;

  @ApiProperty({ format: 'date-time' })
  ultimaVez!: Date;

  @ApiProperty({ type: SesionEnDispositivoResponse, isArray: true })
  sesiones!: SesionEnDispositivoResponse[];
}

export class CierreRemotoResponse {
  @ApiProperty({ example: 1 })
  sesionesCerradas!: number;
}
