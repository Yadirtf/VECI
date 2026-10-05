import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class ServicioSugeridoResponse {
  @ApiProperty({ example: 'Almuerzo' })
  nombre!: string;

  @ApiProperty({ example: '11:30' })
  horaInicio!: string;

  @ApiProperty({ example: '15:00' })
  horaFin!: string;
}

export class TipoDeNegocioResponse {
  @ApiProperty({ example: 'RESTAURANT' })
  codigo!: string;

  @ApiProperty({ example: 'Restaurante' })
  nombre!: string;

  @ApiProperty({ type: ServicioSugeridoResponse, isArray: true })
  servicios!: ServicioSugeridoResponse[];
}

export class MunicipioResponse {
  @ApiProperty({ example: 86001 })
  id!: number;

  @ApiProperty({ example: 'Mocoa' })
  nombre!: string;
}

export class ComercioRegistradoResponse {
  @ApiProperty({ format: 'uuid' })
  comercioId!: string;

  @ApiProperty({ example: 'restaurante-la-vecina' })
  slug!: string;

  @ApiPropertyOptional({
    example: '482915',
    nullable: true,
    type: String,
    description: 'Solo al registrar a nombre de otra persona sin PIN propio. Se muestra una vez.',
  })
  pinTemporal?: string | null;
}

class DocumentoResponse {
  @ApiProperty({ enum: ['NIT', 'CC'] })
  tipo!: string;

  @ApiProperty({ example: '9001234567', description: 'El NIT incluye el dígito de verificación' })
  numero!: string;
}

class ContactoResponse {
  @ApiPropertyOptional({ example: '+573100000101', nullable: true, type: String })
  celular!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  correo!: string | null;
}

class PlanResponse {
  @ApiProperty({ example: 'TRIAL' })
  codigo!: string;

  @ApiProperty({ example: 'Prueba' })
  nombre!: string;

  @ApiProperty({ example: 'TRIAL' })
  estado!: string;

  @ApiProperty({ example: '2026-11-05', description: 'Fecha local del negocio' })
  venceEl!: string;
}

class AvanceResponse {
  @ApiProperty({ example: 2 })
  serviciosConHorario!: number;

  @ApiProperty({ example: 1 })
  cajeros!: number;

  @ApiProperty({ example: 0 })
  tiqueteras!: number;
}

class PasoResponse {
  @ApiProperty({ enum: ['DATOS', 'HORARIOS', 'EQUIPO', 'TIQUETERAS'] })
  codigo!: string;

  @ApiProperty()
  listo!: boolean;

  @ApiProperty({ description: 'Si falta, impide abrir el negocio' })
  obligatorio!: boolean;
}

export class PerfilComercioResponse {
  @ApiProperty({ format: 'uuid' })
  comercioId!: string;

  @ApiProperty({ example: 'Restaurante La Vecina' })
  nombre!: string;

  @ApiProperty({ example: 'la-vecina' })
  slug!: string;

  @ApiProperty({ example: 'RESTAURANT' })
  tipoNegocio!: string;

  @ApiProperty({ type: DocumentoResponse })
  documento!: DocumentoResponse;

  @ApiProperty({ type: ContactoResponse })
  contacto!: ContactoResponse;

  @ApiPropertyOptional({ nullable: true, type: String })
  logoUrl!: string | null;

  @ApiProperty({ example: 'ONBOARDING' })
  estado!: string;

  @ApiProperty({ description: 'Ya vende y registra consumos' })
  abierto!: boolean;

  @ApiPropertyOptional({ type: PlanResponse, nullable: true })
  plan!: PlanResponse | null;

  @ApiProperty({ type: AvanceResponse })
  avance!: AvanceResponse;

  @ApiProperty({ type: PasoResponse, isArray: true })
  camino!: PasoResponse[];

  @ApiProperty()
  puedeAbrir!: boolean;
}
