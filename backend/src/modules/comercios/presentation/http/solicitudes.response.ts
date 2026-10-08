import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class SolicitanteResponse {
  @ApiProperty({ format: 'uuid' })
  usuarioId!: string;

  @ApiProperty({ example: 'Rosa Elena Chindoy' })
  nombre!: string;

  @ApiPropertyOptional({ example: '+573124567890', nullable: true, type: String })
  celular!: string | null;
}

export class SolicitudResponse {
  @ApiProperty({ format: 'uuid' })
  solicitudId!: string;

  @ApiProperty({ enum: ['PENDING', 'APPROVED', 'REJECTED'] })
  estado!: string;

  @ApiProperty({ example: 'Restaurante La Vecina' })
  nombre!: string;

  @ApiProperty({ example: 'RESTAURANT' })
  tipoNegocio!: string;

  @ApiProperty({ enum: ['NIT', 'CC'] })
  tipoDocumento!: string;

  @ApiProperty({ example: '9001234567' })
  numeroDocumento!: string;

  @ApiProperty({ example: '+573100000101' })
  celular!: string;

  @ApiPropertyOptional({ nullable: true, type: String })
  correo!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  logoUrl!: string | null;

  @ApiProperty({ example: 86001 })
  municipioId!: number;

  @ApiProperty({ example: 'Mocoa' })
  municipio!: string;

  @ApiPropertyOptional({ nullable: true, type: String })
  direccion!: string | null;

  @ApiProperty({ type: SolicitanteResponse })
  solicitante!: SolicitanteResponse;

  @ApiPropertyOptional({
    nullable: true,
    type: String,
    description: 'Por qué se rechazó, en palabras para la persona',
  })
  nota!: string | null;

  @ApiPropertyOptional({
    nullable: true,
    type: String,
    format: 'uuid',
    description: 'El negocio que nació al aprobarla',
  })
  comercioId!: string | null;

  @ApiProperty({ type: String, format: 'date-time' })
  radicadaEn!: Date;

  @ApiPropertyOptional({ nullable: true, type: String, format: 'date-time' })
  revisadaEn!: Date | null;
}
