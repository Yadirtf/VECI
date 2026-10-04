import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsString, Matches, MaxLength, ValidateNested } from 'class-validator';
import { DispositivoRequest } from './dispositivo.request';

export class IngresoConPinRequest {
  @ApiProperty({ example: '310 000 0102', description: 'Celular como lo escribe la persona' })
  @IsString()
  @MaxLength(20)
  celular!: string;

  @ApiProperty({ example: '482915', pattern: '^\\d{6}$' })
  @Matches(/^\d{6}$/, { message: 'El PIN son 6 números' })
  pin!: string;

  @ApiProperty({ type: DispositivoRequest })
  @ValidateNested()
  @Type(() => DispositivoRequest)
  dispositivo!: DispositivoRequest;
}

export class IngresoConContrasenaRequest {
  @ApiProperty({ example: 'marta@lavecina.co' })
  @IsString()
  @MaxLength(120)
  correo!: string;

  @ApiProperty({ example: 'almuerzo2026' })
  @IsString()
  @MaxLength(64)
  contrasena!: string;

  @ApiProperty({ type: DispositivoRequest })
  @ValidateNested()
  @Type(() => DispositivoRequest)
  dispositivo!: DispositivoRequest;
}

export class PinNuevoRequest {
  @ApiProperty({ description: 'Token que entregó el ingreso con PIN temporal' })
  @IsString()
  tokenCambio!: string;

  @ApiProperty({ example: '730284', pattern: '^\\d{6}$' })
  @Matches(/^\d{6}$/, { message: 'El PIN son 6 números' })
  pinNuevo!: string;

  @ApiProperty({ type: DispositivoRequest })
  @ValidateNested()
  @Type(() => DispositivoRequest)
  dispositivo!: DispositivoRequest;
}

export class RenovarSesionRequest {
  @ApiProperty()
  @IsString()
  @MaxLength(200)
  tokenRenovacion!: string;
}
