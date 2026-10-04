# Sistema de diseño VECI (HU-01-09)

VECI tiene que sentirse como un vecino aliado: cálido, claro y fácil para personas con poca experiencia digital, que muchas veces usan el celular a pleno sol, con prisa y con una mano. De ahí salen tres reglas:

1. **Grande.** Nada se toca con menos de 48 px; los botones miden 56 px y la acción principal de la caja, 72 px.
2. **Contraste alto.** Todo texto sobre su fondo cumple WCAG AA (4,5:1) y el texto de lectura, AAA (7:1). El generador de tokens falla si un par no cumple.
3. **Pocas palabras y números grandes.** El saldo se lee de lejos (48 px, peso 800).

## Fuente única: [`docs/diseno/tokens.json`](tokens.json)

Los colores y medidas se definen una vez aquí, en la documentación, y cada app genera su versión:

- `web/src/shared/ui/tokens.css` (con `pnpm generar` en `web/`): variables de Tailwind 4 (`bg-selva`, `text-tinta`, `p-m`, `rounded-l`, `h-boton-grande`…).
- `mobile/lib/core/theme/veci_tokens.dart` (con `dart run tool/generar_tokens.dart` en `mobile/`): `VeciColores`, `VeciTexto`, `VeciPeso`, `VeciEspacio`, `VeciRadio`, `VeciToque`.

Nunca escriba un color o un tamaño suelto en el código: agréguelo a `tokens.json`. El CI falla si los archivos generados no coinciden con la fuente.

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
| `crema` | `#FFF8EE` | Fondo de pantalla |
| `superficie` | `#FFFFFF` | Tarjetas |
| `tinta` / `tintaSuave` | `#1C2420` / `#4A564F` | Texto principal y secundario |
| `borde` | `#CFC4B3` | Bordes de campos y tarjetas |
| `aviso` / `avisoFondo` | `#7A4F00` / `#FFF1D6` | Saldo bajo, por vencer |
| `error` / `errorFondo` | `#B3261E` / `#FCE8E6` | Rechazos y errores |

Pares de contraste verificados (texto sobre fondo): tinta/crema, tinta/superficie, tintaSuave/crema y superficie/selvaOscuro ≥ 7; superficie/selva, superficie/arcilla, aviso/avisoFondo, error/errorFondo y éxito/éxitoFondo ≥ 4,5; tinta/maíz ≥ 7.

## Tipografía

| Token | Tamaño | Uso |
| --- | --- | --- |
| `pequeno` | 16 | Ayudas y notas (nunca menos de 16) |
| `cuerpo` | 18 | Texto normal |
| `subtitulo` | 20 | Títulos de tarjeta |
| `titulo` | 24 | Título de pantalla |
| `grande` | 32 | Mensajes de confirmación |
| `saldo` | 48 | El número del saldo |

Pesos: 400, 600 y 800. El panel usa **Nunito** (redondeada y amable, cargada con `next/font`). La app usa la fuente del sistema (Roboto en Android) para no agrandar la instalación en celulares de gama baja; si las pruebas con cajeros piden Nunito también en la app, se agrega como recurso.

## Componentes base

| Componente | Panel (`@/shared/ui`) | App (`core/ui`) | Notas |
| --- | --- | --- | --- |
| Botón | `Boton` (`primario`, `secundario`, `peligro`; `grande`) | `VeciBoton` (`grande`) | Alto 56 o 72 px, ancho completo en la app, foco visible en maíz |
| Tarjeta | `Tarjeta` | `VeciTarjeta` | Superficie blanca, radio 16, borde suave |
| Campo de texto | `Campo` | `TextField` con el tema de campos de `VeciTema` | Etiqueta siempre visible, borde de 2 px y foco en verde selva |
| Aviso | `Aviso` (`exito`, `aviso`, `error`) | `VeciAviso` (`TonoAviso`) | Ícono más texto: el color nunca es la única señal |
| Saldo | `Saldo` | `VeciSaldo` | Número de 48 px y unidad en singular o plural (“1 almuerzo”, “12 almuerzos”) |

El tema de la app está en `core/theme/veci_tema.dart` (Material 3 con los tokens) y el del panel en `app/globals.css`.
