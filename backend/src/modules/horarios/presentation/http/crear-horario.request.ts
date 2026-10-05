import { ApiProperty } from '@nestjs/swagger';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
} from 'class-validator';

const HORA = /^([01]\d|2[0-3]):[0-5]\d$/;

export class CrearHorarioRequest {
  @ApiProperty({ format: 'uuid', description: 'Servicio (desayuno, almuerzo...)' })
  @IsUUID()
  servicioId!: string;

  @ApiProperty({ format: 'uuid', description: 'Sede donde aplica el horario' })
  @IsUUID()
  sedeId!: string;

  @ApiProperty({
    example: ['MONDAY', 'TUESDAY'],
    type: [String],
    description: 'Códigos de los días (catálogo de días). Varios copian el horario.',
  })
  @IsArray()
  @ArrayMinSize(1)
  @ArrayMaxSize(7)
  @Matches(/^[A-Z][A-Z0-9_]*$/, { each: true, message: 'cada día debe ser un código como MONDAY' })
  dias!: string[];

  @ApiProperty({ example: '11:30', pattern: HORA.source })
  @Matches(HORA, { message: 'horaInicio debe tener el formato HH:MM' })
  horaInicio!: string;

  @ApiProperty({ example: '15:00', pattern: HORA.source })
  @Matches(HORA, { message: 'horaFin debe tener el formato HH:MM' })
  horaFin!: string;
}

export class EditarHorarioRequest {
  @ApiProperty({ example: '11:30', pattern: HORA.source })
  @Matches(HORA, { message: 'horaInicio debe tener el formato HH:MM' })
  horaInicio!: string;

  @ApiProperty({ example: '15:00', pattern: HORA.source })
  @Matches(HORA, { message: 'horaFin debe tener el formato HH:MM' })
  horaFin!: string;
}

export class EstadoHorarioRequest {
  @ApiProperty({ description: 'false lo pone en pausa; true lo reanuda' })
  @IsBoolean()
  activo!: boolean;
}

export class CrearServicioRequest {
  @ApiProperty({ example: 'Cena' })
  @IsString()
  @MaxLength(60)
  nombre!: string;
}
