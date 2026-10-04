import { ApiProperty } from '@nestjs/swagger';
import { IsUUID, Matches } from 'class-validator';

const HORA = /^([01]\d|2[0-3]):[0-5]\d$/;

export class CrearHorarioRequest {
  @ApiProperty({ format: 'uuid', description: 'Servicio (desayuno, almuerzo...)' })
  @IsUUID()
  servicioId!: string;

  @ApiProperty({ format: 'uuid', description: 'Sede donde aplica el horario' })
  @IsUUID()
  sedeId!: string;

  @ApiProperty({ example: 'MONDAY', description: 'Código del día (catálogo de días)' })
  @Matches(/^[A-Z][A-Z0-9_]*$/, { message: 'dia debe ser un código como MONDAY' })
  dia!: string;

  @ApiProperty({ example: '11:30', pattern: HORA.source })
  @Matches(HORA, { message: 'horaInicio debe tener el formato HH:MM' })
  horaInicio!: string;

  @ApiProperty({ example: '15:00', pattern: HORA.source })
  @Matches(HORA, { message: 'horaFin debe tener el formato HH:MM' })
  horaFin!: string;
}
