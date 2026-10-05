import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class HorarioResponse {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ format: 'uuid' })
  servicioId!: string;

  @ApiPropertyOptional({ example: 'Almuerzo' })
  servicioNombre?: string;

  @ApiProperty({ format: 'uuid' })
  sedeId!: string;

  @ApiProperty({ example: 'MONDAY' })
  dia!: string;

  @ApiProperty({ example: '11:30' })
  horaInicio!: string;

  @ApiProperty({ example: '15:00' })
  horaFin!: string;

  @ApiProperty({ description: 'false = en pausa: no cuenta para la caja' })
  activo!: boolean;
}

export class ServicioResponse {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'Almuerzo' })
  nombre!: string;
}
