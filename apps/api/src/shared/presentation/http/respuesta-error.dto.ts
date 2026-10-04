import { ApiProperty } from '@nestjs/swagger';

/** Forma de las respuestas de error de reglas del negocio. */
export class RespuestaErrorDto {
  @ApiProperty({ example: 422 })
  statusCode!: number;

  @ApiProperty({ example: 'HORARIO_SE_CRUZA' })
  codigo!: string;

  @ApiProperty({ example: 'Ese horario se cruza con otro del mismo día en esta sede.' })
  message!: string;
}
