import { ArgumentsHost, Catch, ExceptionFilter, HttpStatus } from '@nestjs/common';
import type { Response } from 'express';
import { ErrorDeDominio, TipoDeError } from '../../../domain/errores/error-de-dominio';

const ESTADO_HTTP: Record<TipoDeError, HttpStatus> = {
  'no-encontrado': HttpStatus.NOT_FOUND,
  conflicto: HttpStatus.CONFLICT,
  'regla-incumplida': HttpStatus.UNPROCESSABLE_ENTITY,
  'no-autenticado': HttpStatus.UNAUTHORIZED,
  prohibido: HttpStatus.FORBIDDEN,
};

/** Traduce los errores del negocio a HTTP con un código estable y un mensaje cercano. */
@Catch(ErrorDeDominio)
export class ErroresDeDominioFilter implements ExceptionFilter {
  catch(error: ErrorDeDominio, host: ArgumentsHost): void {
    const estado = ESTADO_HTTP[error.tipo];
    host
      .switchToHttp()
      .getResponse<Response>()
      .status(estado)
      .json({ statusCode: estado, codigo: error.codigo, message: error.message });
  }
}
