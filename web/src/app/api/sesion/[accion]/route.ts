import { type NextRequest, NextResponse } from 'next/server';
import { atenderSesion, COOKIE_DISPOSITIVO, COOKIE_RENOVACION } from '@/features/sesion/servidor';

export const dynamic = 'force-dynamic';

async function leerCuerpo(request: NextRequest): Promise<Record<string, unknown>> {
  try {
    const cuerpo: unknown = await request.json();
    return cuerpo && typeof cuerpo === 'object' ? (cuerpo as Record<string, unknown>) : {};
  } catch {
    return {};
  }
}

/** Ingreso, PIN nuevo, renovación y salida del panel; la cookie de renovación solo vive aquí. */
export async function POST(request: NextRequest, ctx: { params: Promise<{ accion: string }> }) {
  const { accion } = await ctx.params;
  const respuesta = await atenderSesion({
    accion,
    cuerpo: await leerCuerpo(request),
    renovacion: request.cookies.get(COOKIE_RENOVACION)?.value,
    dispositivoId: request.cookies.get(COOKIE_DISPOSITIVO)?.value,
    agente: request.headers.get('user-agent'),
    autorizacion: request.headers.get('authorization'),
  });
  const salida =
    respuesta.estado === 204
      ? new NextResponse(null, { status: 204 })
      : NextResponse.json(respuesta.cuerpo, { status: respuesta.estado });
  for (const { nombre, valor, ...opciones } of respuesta.cookies) {
    salida.cookies.set(nombre, valor, opciones);
  }
  salida.headers.set('cache-control', 'no-store');
  return salida;
}
