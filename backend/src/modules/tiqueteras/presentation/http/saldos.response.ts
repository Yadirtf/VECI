import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { UnidadResponse } from './tipos.response';

const ESTADOS_TIQUETERA = ['ACTIVE', 'DEPLETED', 'EXPIRED', 'VOIDED'];
const TIPOS_DE_EVENTO = [
  'SALE',
  'CONSUMPTION',
  'CONSUMPTION_REVERSAL',
  'SALE_VOID',
  'ADJUSTMENT',
  'EXPIRATION',
];

export class TiqueteraResponse {
  @ApiProperty({ format: 'uuid' })
  tiqueteraId!: string;

  @ApiProperty({ format: 'uuid' })
  clienteId!: string;

  @ApiProperty({ format: 'uuid' })
  ventaId!: string;

  @ApiProperty({ format: 'uuid' })
  tipoId!: string;

  @ApiProperty({ example: 'Tiquetera de 20 almuerzos' })
  nombre!: string;

  @ApiProperty({ type: UnidadResponse })
  unidad!: UnidadResponse;

  @ApiProperty({ example: 20 })
  compradas!: number;

  @ApiProperty({ example: 14 })
  saldo!: number;

  @ApiProperty({ enum: ESTADOS_TIQUETERA })
  estado!: string;

  @ApiProperty({ format: 'date-time' })
  compradaEn!: Date;

  @ApiProperty({ format: 'date-time', description: 'Desde este instante ya no sirve' })
  venceEn!: Date;

  @ApiProperty({ example: '2026-11-06', description: 'Último día en que sirve (fecha local)' })
  ultimoDia!: string;

  @ApiProperty({ description: 'Tiene unidades y no ha vencido' })
  vigente!: boolean;

  @ApiPropertyOptional({
    example: 1,
    nullable: true,
    type: Number,
    description: '1 = la que se gasta primero (la que vence antes)',
  })
  turno!: number | null;

  @ApiPropertyOptional({
    example: 220000,
    nullable: true,
    type: Number,
    description: 'Lo que se cobró; null en la app del cliente',
  })
  precio!: number | null;
}

export class SaldoResponse {
  @ApiProperty({ type: UnidadResponse })
  unidad!: UnidadResponse;

  @ApiProperty({ example: 14 })
  disponibles!: number;

  @ApiProperty({ format: 'date-time', description: 'Vencimiento de la que se gasta primero' })
  proximoVencimiento!: Date;

  @ApiProperty({ example: '2026-11-06' })
  ultimoDia!: string;

  @ApiProperty({ example: 2, description: 'Tiqueteras vigentes que suman ese saldo' })
  tiqueteras!: number;
}

export class MovimientoResponse {
  @ApiProperty({ format: 'uuid' })
  eventoId!: string;

  @ApiProperty({ enum: TIPOS_DE_EVENTO })
  tipo!: string;

  @ApiProperty({ format: 'date-time' })
  ocurridoEn!: Date;

  @ApiProperty({ example: -1, description: 'Unidades que sumó (+) o quitó (-)' })
  unidades!: number;

  @ApiPropertyOptional({ nullable: true, type: String, example: 'Tiquetera de 20 almuerzos' })
  tiquetera!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String, example: 'Error al registrar' })
  motivo!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  nota!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String, example: 'Rosa Elena' })
  quien!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String, format: 'uuid' })
  corrigeA!: string | null;
}

export class EstadoDeCuentaResponse {
  @ApiProperty({ format: 'uuid' })
  clienteId!: string;

  @ApiProperty({ type: SaldoResponse, isArray: true, description: 'Saldo por unidad' })
  saldos!: SaldoResponse[];

  @ApiProperty({ type: TiqueteraResponse, isArray: true })
  tiqueteras!: TiqueteraResponse[];

  @ApiProperty({ type: MovimientoResponse, isArray: true, description: 'Lo más reciente primero' })
  movimientos!: MovimientoResponse[];
}

export class PagoResponse {
  @ApiProperty({ example: 'BANK_TRANSFER' })
  medio!: string;

  @ApiPropertyOptional({ example: 'NEQUI', nullable: true, type: String })
  canal!: string | null;

  @ApiPropertyOptional({ nullable: true, type: String })
  referencia!: string | null;
}

export class VentaResponse {
  @ApiProperty({ format: 'uuid' })
  ventaId!: string;

  @ApiProperty({ format: 'uuid' })
  clienteId!: string;

  @ApiProperty({ description: 'Ya había llegado: no se registró otra vez' })
  repetida!: boolean;

  @ApiProperty({ enum: ['ONLINE', 'OFFLINE_SYNC'] })
  origen!: string;

  @ApiProperty({ type: TiqueteraResponse, description: 'La tiquetera que se vendió' })
  tiquetera!: TiqueteraResponse;

  @ApiProperty({ type: SaldoResponse, isArray: true })
  saldos!: SaldoResponse[];

  @ApiProperty({ type: TiqueteraResponse, isArray: true })
  tiqueteras!: TiqueteraResponse[];
}

export class VentaResumenResponse {
  @ApiProperty({ format: 'uuid' })
  ventaId!: string;

  @ApiProperty({ format: 'uuid' })
  clienteId!: string;

  @ApiProperty({ example: 'Luz Marina Chindoy' })
  cliente!: string;

  @ApiProperty({ example: 'Tiquetera de 20 almuerzos' })
  tiquetera!: string;

  @ApiProperty({ example: 220000 })
  precio!: number;

  @ApiProperty({ type: PagoResponse })
  pago!: PagoResponse;

  @ApiProperty({ format: 'date-time' })
  ocurridaEn!: Date;

  @ApiProperty({ enum: ['ONLINE', 'OFFLINE_SYNC'] })
  origen!: string;

  @ApiProperty({ enum: ['COMPLETED', 'VOIDED'] })
  estado!: string;

  @ApiPropertyOptional({ nullable: true, type: String, example: 'Rosa Elena' })
  cajero!: string | null;

  @ApiProperty({ example: 14, description: 'Unidades que le quedan a esa tiquetera' })
  saldo!: number;
}

export class MisTiqueterasResponse {
  @ApiProperty({ format: 'uuid' })
  comercioId!: string;

  @ApiProperty({ example: 'Restaurante Doña Rosa' })
  comercio!: string;

  @ApiProperty({ type: SaldoResponse, isArray: true })
  saldos!: SaldoResponse[];

  @ApiProperty({ type: TiqueteraResponse, isArray: true })
  tiqueteras!: TiqueteraResponse[];
}
