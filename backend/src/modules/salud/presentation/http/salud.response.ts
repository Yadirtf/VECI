import { ApiProperty } from '@nestjs/swagger';

export class SaludResponse {
  @ApiProperty({ enum: ['ok', 'degradado'] })
  estado!: 'ok' | 'degradado';

  @ApiProperty({ enum: ['ok', 'sin-conexion'] })
  baseDatos!: 'ok' | 'sin-conexion';

  @ApiProperty({ example: '0.1.0+abc1234' })
  version!: string;
}
