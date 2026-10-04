import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsUUID, Matches, MaxLength } from 'class-validator';

export class ComercioActivoRequest {
  @ApiProperty({ format: 'uuid' })
  @IsUUID()
  comercioId!: string;
}

export class CambiarPinRequest {
  @ApiProperty({ pattern: '^\\d{6}$' })
  @Matches(/^\d{6}$/, { message: 'El PIN son 6 números' })
  pinActual!: string;

  @ApiProperty({ pattern: '^\\d{6}$' })
  @Matches(/^\d{6}$/, { message: 'El PIN son 6 números' })
  pinNuevo!: string;
}

export class CorreoYContrasenaRequest {
  @ApiProperty({ example: 'marta@lavecina.co' })
  @IsString()
  @MaxLength(120)
  correo!: string;

  @ApiProperty({ example: 'almuerzo2026', minLength: 8 })
  @IsString()
  @MaxLength(64)
  contrasena!: string;

  @ApiProperty({ pattern: '^\\d{6}$', description: 'PIN actual, para confirmar que eres tú' })
  @Matches(/^\d{6}$/, { message: 'El PIN son 6 números' })
  pinActual!: string;
}
