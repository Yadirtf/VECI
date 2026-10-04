import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class EspacioResponse {
  @ApiProperty({ format: 'uuid' })
  comercioId!: string;

  @ApiProperty({ example: 'Restaurante La Vecina' })
  nombre!: string;

  @ApiProperty({ example: 'RESTAURANT', description: 'Código del tipo de negocio' })
  tipoNegocio!: string;

  @ApiProperty({ example: ['CASHIER'], description: 'OWNER, CASHIER o CUSTOMER', type: [String] })
  roles!: readonly string[];

  @ApiProperty({ description: 'Lo invitaron como cajero y aún no ha entrado a este negocio' })
  invitacionPendiente!: boolean;
}

export class UsuarioResponse {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'Jhon' })
  nombre!: string;
}

export class SesionResponse {
  @ApiProperty({ description: 'Va en Authorization: Bearer. Dura 15 minutos.' })
  tokenAcceso!: string;

  @ApiProperty({ description: 'Se cambia por uno nuevo en cada renovación; guárdelo seguro.' })
  tokenRenovacion!: string;

  @ApiProperty({ example: 900 })
  segundosAcceso!: number;

  @ApiProperty({ type: UsuarioResponse })
  usuario!: UsuarioResponse;

  @ApiProperty({ type: EspacioResponse, isArray: true })
  espacios!: EspacioResponse[];
}

export class IngresoResponse {
  @ApiProperty({ description: 'Entró con un PIN temporal: debe crear el suyo antes de seguir' })
  requiereCambioDePin!: boolean;

  @ApiProperty({ example: 'Jhon' })
  nombre!: string;

  @ApiPropertyOptional({ description: 'Solo si requiereCambioDePin. Dura 10 minutos.' })
  tokenCambio?: string;

  @ApiPropertyOptional({ type: SesionResponse })
  sesion?: SesionResponse;
}

export class ComercioActivoResponse {
  @ApiProperty({ type: EspacioResponse })
  comercio!: EspacioResponse;

  @ApiProperty({ example: ['consumptions.register'], type: [String] })
  permisos!: string[];
}

export class CorreoResponse {
  @ApiProperty({ example: 'marta@lavecina.co' })
  correo!: string;
}
