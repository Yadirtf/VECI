import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsISO8601,
  IsObject,
  IsString,
  IsUUID,
  ValidateNested,
} from 'class-validator';

/** Tope por lote: 1.000 eventos pendientes viajan en 10 lotes de 100. */
export const MAX_EVENTS_PER_BATCH = 500;

export class EventoRequest {
  @IsUUID()
  id!: string;

  @IsString()
  kind!: string;

  @IsISO8601({ strict: true })
  occurred_at!: string;

  @IsObject()
  payload!: Record<string, unknown>;
}

export class RecibirLoteRequest {
  @IsUUID()
  batch_id!: string;

  @IsUUID()
  device_id!: string;

  @IsUUID()
  tenant_id!: string;

  @ValidateNested({ each: true })
  @ArrayMinSize(1)
  @ArrayMaxSize(MAX_EVENTS_PER_BATCH)
  @Type(() => EventoRequest)
  events!: EventoRequest[];
}
