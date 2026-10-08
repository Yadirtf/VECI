import {
  Inject,
  Injectable,
  Logger,
  OnApplicationBootstrap,
  OnApplicationShutdown,
} from '@nestjs/common';
import {
  CONFIGURACION,
  Configuracion,
} from '../../../../shared/infrastructure/config/configuracion';
import { VencerTiqueteras } from '../../application/use-cases/vencer.use-case';

/** Cada hora: una tiquetera vencida deja de contar aunque el proceso se atrase (ADR-0018). */
export const CADA_HORA_MS = 60 * 60 * 1000;

/**
 * Corre el vencimiento al arrancar la API y luego cada hora (HU-05-04). Nada depende de
 * que corra a tiempo: el saldo ya filtra por la fecha de vencimiento; esto deja el estado
 * y el movimiento en el libro para los reportes. Dos instancias pueden correrlo a la vez:
 * cada tiquetera se bloquea y se salta si otra ya la está venciendo.
 */
@Injectable()
export class ProgramadorDeVencimiento implements OnApplicationBootstrap, OnApplicationShutdown {
  private readonly bitacora = new Logger('Vencimiento');
  private temporizador: NodeJS.Timeout | null = null;
  private enCurso: Promise<void> | null = null;

  constructor(
    private readonly vencer: VencerTiqueteras,
    @Inject(CONFIGURACION) private readonly config: Configuracion,
  ) {}

  onApplicationBootstrap(): void {
    if (!this.config.vencimientoAutomatico) return;
    void this.correr();
    this.temporizador = setInterval(() => void this.correr(), CADA_HORA_MS);
    this.temporizador.unref();
  }

  async onApplicationShutdown(): Promise<void> {
    if (this.temporizador) clearInterval(this.temporizador);
    this.temporizador = null;
    await this.enCurso;
  }

  /** Una vuelta a la vez; si la anterior sigue, esta se salta. */
  correr(): Promise<void> {
    this.enCurso ??= this.vuelta().finally(() => {
      this.enCurso = null;
    });
    return this.enCurso;
  }

  private async vuelta(): Promise<void> {
    try {
      const r = await this.vencer.ejecutar();
      if (r.tiqueteras > 0 || r.fallidos > 0) {
        this.bitacora.log(
          `Vencidas ${r.tiqueteras} tiqueteras en ${r.comercios} comercios (${r.fallidos} fallidos).`,
        );
      }
    } catch (error) {
      this.bitacora.error('No se pudo revisar el vencimiento de las tiqueteras.', error);
    }
  }
}
