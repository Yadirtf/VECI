'use client';

import { useCallback, useState } from 'react';

const RESPALDO = 'Algo no salió bien. Intenta otra vez en un momento.';

/** Estado de un botón que llama al servidor: ocupado mientras va y el mensaje si falla. */
export function useAccion() {
  const [ocupado, setOcupado] = useState(false);
  const [problema, setProblema] = useState<string | null>(null);

  const ejecutar = useCallback(async (accion: () => Promise<void>): Promise<boolean> => {
    setOcupado(true);
    setProblema(null);
    try {
      await accion();
      return true;
    } catch (error) {
      setProblema(error instanceof Error && error.message ? error.message : RESPALDO);
      return false;
    } finally {
      setOcupado(false);
    }
  }, []);

  return { ocupado, problema, setProblema, ejecutar };
}
