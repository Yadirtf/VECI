import { toDataURL } from 'qrcode';
import { DemoQr } from '../../domain/demo-qr';

const EXPECTED_TEXT: Record<DemoQr['expected'], string> = {
  VALIDO: 'Debe aceptarse',
  REVOCADO: 'Debe rechazarse: QR revocado',
  OTRO_COMERCIO: 'Debe rechazarse: es de otro restaurante',
  FIRMA_INVALIDA: 'Debe rechazarse: firma inválida',
};

/** Página HTML imprimible con los QR de prueba. */
export async function renderHojaDePrueba(sheet: DemoQr[]): Promise<string> {
  const cards = await Promise.all(sheet.map(renderCard));
  return `<!doctype html>
<html lang="es"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>VECI · QR de prueba</title>
<style>
  body { font-family: system-ui, sans-serif; margin: 16px; color: #1f2937; }
  .grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 16px; }
  .card { border: 1px solid #d1d5db; border-radius: 12px; padding: 12px; text-align: center; }
  .card img { width: 100%; max-width: 240px; }
  .hint { font-size: 13px; color: #4b5563; }
</style></head>
<body>
<h1>VECI · Hoja de QR de prueba (HU-00-04)</h1>
<p>Baja los datos offline en la app, apaga el internet del celular y escanea cada QR.</p>
<div class="grid">${cards.join('')}</div>
</body></html>`;
}

async function renderCard(qr: DemoQr): Promise<string> {
  const image = await toDataURL(qr.token, { errorCorrectionLevel: 'M', margin: 2, width: 480 });
  return `<div class="card"><img alt="${qr.label}" src="${image}">
<h3>${qr.label}</h3><p class="hint">${EXPECTED_TEXT[qr.expected]}</p></div>`;
}
