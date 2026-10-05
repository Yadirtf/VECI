# Sistema de diseño VECI (HU-01-09)

VECI tiene que sentirse como un vecino aliado: cálido, claro y fácil para personas con poca experiencia digital, que muchas veces usan el celular a pleno sol, con prisa y con una mano. De ahí salen tres reglas:

Desde octubre de 2026 la dirección visual es **«El papelito del vecino»** (ver [exploración](exploracion-rediseno-2026-10.md)): la interfaz se parece a la tiquetera de cartón y al talonario que la gente ya conoce, y la forma de cada cosa dice qué es.

1. **Grande.** Nada se toca con menos de 48 px; los botones miden 56 px y la acción principal de la caja, 72 px.
2. **Contraste alto.** Todo texto sobre su fondo cumple WCAG AA (4,5:1) y el texto de lectura, AAA (7:1). El generador de tokens falla si un par no cumple.
3. **Pocas palabras y números grandes.** El saldo se lee de lejos (48 px, peso 800).

## Fuente única: [`docs/diseno/tokens.json`](tokens.json)

Los colores y medidas se definen una vez aquí, en la documentación, y cada app genera su versión:

- `web/src/shared/ui/tokens.css` (con `pnpm generar` en `web/`): variables de Tailwind 4 (`bg-selva`, `text-tinta`, `p-m`, `rounded-l`, `h-boton-grande`…).
- `mobile/lib/core/theme/veci_tokens.dart` (con `dart run tool/generar_tokens.dart` en `mobile/`): `VeciColores`, `VeciTexto`, `VeciPeso`, `VeciEspacio`, `VeciRadio`, `VeciToque`.

Nunca escriba un color o un tamaño suelto en el código: agréguelo a `tokens.json`. El CI falla si los archivos generados no coinciden con la fuente.

## Gramática de formas

| Forma | Significa | App (`core/theme/veci_formas.dart`) | Panel (`app/globals.css`) |
| --- | --- | --- | --- |
| Papelito dentado (dientes de 12 × 6 px, sombra dura) | VECI te habla | `PapelitoBorder` en `VeciTarjeta` y `VeciAviso` | `papelito` (+ `perforado`) |
| Piedra de canto con canto de 6 px | Lo que tú haces | `VeciFormas.piedra()` en `VeciBoton` | `tecla piedra` (`clasesBoton()`) |
| Esquinas cortadas | Cuidado, no se deshace | `VeciFormas.chaflan()` (`VeciBoton(peligro: true)`) | `Boton variante="peligro"` |
| Colilla con muescas | El saldo | `ColillaBorder` en `VeciSaldo` | `colilla` en `Saldo` |
| Arco | Dónde estás / zona del pulgar | `ArcoBorder` en `VeciEncabezado`, `VeciMostrador` y todo `AppBar` | `arco-abajo`, `ventanilla` |

Sello de los avisos: círculo = éxito, triángulo = aviso, octágono = error. Las medidas viven en el grupo `forma` de `tokens.json`.

## Paleta

Inspirada en el Putumayo: verde de la selva, arcilla del río y maíz.

| Token | Color | Uso |
| --- | --- | --- |
| `selva` | `#14684A` | Acción principal, marca, éxito |
| `selvaOscuro` | `#0D4A34` | Encabezados sobre claro, botón presionado |
| `selvaClaro` | `#DDF0E6` | Fondos de confirmación |
| `arcilla` | `#9C4421` | Acción secundaria destacada |
| `arcillaClaro` | `#F8E3D8` | Fondos suaves |
| `maiz` | `#F2B33D` | Foco del teclado, resaltados (siempre con texto `tinta`) |
| `crema` | `#F5ECDC` | Fondo de pantalla (papel kraft) |
| `superficie` | `#FFFDF8` | Papelitos y campos |
| `tinta` / `tintaSuave` | `#1C2420` / `#3E4A43` | Texto principal y secundario (ambos AAA) |
| `borde` | `#8C7F6B` | Bordes y casillas (≥ 3:1, WCAG 1.4.11) |
| `sombraPapel` | `#8A7A62` | Sombra dura de los papelitos |
| `arcillaOscuro`, `errorOscuro` | `#6E2E14`, `#5C1410` | Canto de botones |
| `aviso` / `avisoFondo` | `#5E3D00` / `#FFF1D6` | Saldo bajo, por vencer |
| `error` / `errorFondo` | `#8E1F18` / `#FCE8E6` | Rechazos y errores |

Los pares de contraste verificados están en `contraste.pares` de `tokens.json`: avisos y errores ahora cumplen AAA (7:1) y los bordes, 3:1.

## Tipografía

| Token | Tamaño | Uso |
| --- | --- | --- |
| `pequeno` | 16 | Ayudas y notas (nunca menos de 16) |
| `cuerpo` | 18 | Texto normal |
| `subtitulo` | 20 | Títulos de tarjeta |
| `titulo` | 24 | Título de pantalla |
| `grande` | 32 | Mensajes de confirmación |
| `saldo` | 48 | El número del saldo |
| `sello` | 64 | La cifra del sello al registrar |

Pesos: 400, 600 y 800. El panel usa **Nunito** para el texto y **Baloo 2** (letra de letrero pintado) para títulos, ambas con `next/font`. Las cifras usan números tabulares. La app usa la fuente del sistema (Roboto en Android) para no agrandar la instalación en celulares de gama baja; si las pruebas con cajeros piden Nunito también en la app, se agrega como recurso.

## Componentes base

| Componente | Panel (`@/shared/ui`) | App (`core/ui`) | Notas |
| --- | --- | --- | --- |
| Botón | `Boton` (`primario`, `secundario`, `peligro`; `grande`) y `clasesBoton()` para enlaces | `VeciBoton` (`grande`, `secundario`, `peligro`) | Piedra con canto que baja al tocarla; alto 56 o 72 px; foco visible en maíz |
| Tarjeta | `Tarjeta` (`perforado`) | `VeciTarjeta` (`perforado`) | Papelito dentado con sombra dura |
| Campo de texto | `Campo` | `TextField` con el tema de campos de `VeciTema` | Renglón de cuaderno: línea de 3 px abajo, etiqueta siempre visible, foco en verde selva |
| Aviso | `Aviso` (`exito`, `aviso`, `error`) | `VeciAviso` (`TonoAviso`) | Papelito perforado con un sello de forma distinta por tono |
| Saldo | `Saldo` (`total` opcional) | `VeciSaldo` (`total` opcional) | Colilla con número de 48 px, unidad en singular o plural y, con `total`, la tiquetera de casillas |
| Sello | `Sello` | `VeciSello` | Cae al registrar, torcido según el consumo; en la app vibra corto |
| PIN | `Campo` tipo contraseña | `VeciPin` | Una casilla por número que se perfora al escribir |
| Encabezado | `MarcoPanel` | `VeciEncabezado` | Banda en arco con el saludo y el negocio |
| Mostrador | — | `VeciMostrador` | La acción principal abajo, al alcance del pulgar; sube con el teclado |

El tema de la app está en `core/theme/veci_tema.dart` (Material 3 con los tokens) y el del panel en `app/globals.css`.
