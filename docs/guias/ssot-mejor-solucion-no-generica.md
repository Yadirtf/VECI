# Guía: buscar la mejor solución, no la predecible (SSoT)

Versión 1.0 · 4 de octubre de 2026 · pedida por Ing. Yadir

**Cuándo se lee:** antes de empezar cada épica o historia de VECI, y cada vez que se coordinen varios agentes sobre una misma tarea. Es parte de la definición de listo del [backlog](../backlog.md).

## 1. De dónde sale

Sakana AI publicó *String Seed of Thought: Prompting LLMs for Distribution-Faithful and Diverse Generation* ([página](https://pub.sakana.ai/ssot/), [artículo](https://arxiv.org/abs/2510.21150)). La investigación muestra algo que afecta cómo trabajamos con IA en VECI:

- **Los modelos de lenguaje tienden a la respuesta más probable.** Si se les pide "lanza una moneda justa", responden cara ~78 % de las veces. Si se les pide una idea, un nombre o un diseño, caen en el mismo puñado de respuestas típicas. Eso es lo "genérico" y "predecible".
- **La técnica SSoT lo corrige sin herramientas externas.** Se le pide al modelo que primero escriba una cadena aleatoria compleja y que luego la *manipule* para tomar cada decisión abierta. Con eso la moneda pasa a ~51 / 49 y las respuestas abiertas ganan diversidad medible (NoveltyBench, WildChat).
- **Los modelos inventan solos buenas estrategias** para usar la semilla: sumar los códigos ASCII y sacar módulo (elegir entre opciones iguales), un hash rodante con umbrales (elegir con probabilidades distintas) y, en tareas creativas, descomponer la respuesta en ejes (escenario, rasgos, conflicto…) y elegir cada eje con un tramo distinto de la cadena.
- **Más razonamiento = mejor resultado.** Las trazas más largas muestrean con más fidelidad; vale la pena gastar tokens en pensar las decisiones abiertas.
- **Límite explícito:** SSoT *no* sirve para tareas con una sola respuesta correcta (matemáticas, datos, una regla de negocio). Ahí la diversidad estorba.

## 2. Qué significa para VECI

La lección no es "ser aleatorio", es **separar dos momentos** y no dejar que la primera idea que aparece sea la que se construye:

| Momento | Objetivo | Cómo se trabaja |
| --- | --- | --- |
| **Abrir (divergir)** | Ver el espacio real de soluciones, no solo la obvia. | Diversidad forzada: varias alternativas de verdad distintas, cada una desde un eje diferente. Aquí aplica SSoT. |
| **Cerrar (converger)** | Elegir la mejor para VECI y hacerla bien. | Criterios explícitos y evidencia. Aquí *no* aplica SSoT: hay una respuesta mejor y se defiende con datos, pruebas y el modelo de datos. |

La regla de negocio, el saldo, la seguridad y el aislamiento multi-comercio son del segundo momento: tienen respuesta correcta y se prueban. El diseño de un flujo, una pantalla, un mensaje, una forma de resolver un caso difícil o una arquitectura entre varias válidas son del primero.

## 3. Protocolo para cada épica

1. **Leer** la épica, sus historias, los requerimientos que trazan, el modelo de datos (`docs/arquitectura/modelo-datos`) y los ADR que la tocan. Nada de suponer.
2. **Listar las decisiones abiertas** de la épica: dónde hay más de una forma razonable de hacerlo (flujo de usuario, seguridad, datos, offline, UX, textos).
3. **Abrir el abanico en cada decisión importante:** al menos 3 alternativas *genuinamente* distintas. Para no caer en variaciones de la misma idea, cada una sale de un eje distinto, por ejemplo:
   - el usuario real (cajera en hora pico, señor mayor con celular de gama baja, dueño en el computador del negocio);
   - el contexto del Putumayo (señal intermitente, Android de 2 GB, pagos por Nequi o efectivo);
   - la seguridad o el fraude;
   - el costo y la simplicidad de operar;
   - reutilizar lo que ya existe en el modelo de datos.
4. **Cerrar con criterios de VECI**, en este orden: correcto y seguro → funciona sin internet y en gama baja → cercano y fácil (tono VECI) → simple de mantener (arquitectura limpia, sin dependencias innecesarias) → barato de operar.
5. **Preferir el mecanismo que resuelve varias historias a la vez** sobre una solución por historia (por ejemplo, un mismo "PIN temporal que se cambia al entrar" para invitar cajeros y para restablecer PIN).
6. **Dejar constancia:** en el PR (o en un ADR si es estructural) va la alternativa elegida y, en una línea cada una, las descartadas y por qué. Así la siguiente persona no repite la discusión.
7. **Revisar contra lo genérico antes de entregar** (sección 5).

## 4. Coordinar varios agentes sin que todos digan lo mismo

Varios agentes con el mismo encargo convergen a la misma respuesta típica; tenerlos en paralelo no da diversidad por sí solo. Para que valga la pena:

- **Darle a cada agente un eje o una semilla distinta** (por ejemplo: "explora desde el fraude", "explora desde la cajera en hora pico", "explora reutilizando solo tablas existentes"). Nunca el mismo encargo palabra por palabra.
- **Cuando se pida exploración abierta**, incluir en sus instrucciones la versión en español del prompt SSoT simplificado:

  > Debes proponer exactamente una solución única y distinta a la obvia. Para lograrlo, primero genera una cadena aleatoria compleja entre `<cadena_aleatoria>` y `</cadena_aleatoria>`, y manipúlala (por ejemplo, sumando los códigos de sus caracteres y sacando módulo) para guiar cada decisión abierta dentro de `<pensamiento>` y `</pensamiento>`. Luego justifica la propuesta contra los criterios de VECI.

- **No usar la semilla para lo que tiene respuesta única**: corregir un bug, aplicar una regla de saldo, escribir una migración o una prueba. Ahí se pide precisión y verificación, no variedad.
- **El coordinador compara y decide** con los criterios de la sección 3; no promedia propuestas ni elige la que más se repite (la que más se repite suele ser la más genérica).

## 5. Lista anti-genérico (antes de entregar)

- [ ] ¿Esta solución es la primera que se me ocurrió? Si sí, ¿la comparé con al menos dos distintas?
- [ ] ¿Funciona para una cajera en hora pico, con señal mala y un celular de gama baja?
- [ ] ¿Los textos suenan a VECI ([guía de tono](../diseno/guia-de-tono.md)) y no a un software cualquiera ("Error 401", "Credenciales inválidas")?
- [ ] ¿Reutilicé lo que ya existe (modelo de datos, catálogos, módulos) antes de inventar tablas, dependencias o pantallas?
- [ ] ¿Un mismo mecanismo resuelve varias historias, o hice un parche por historia?
- [ ] ¿Las reglas están en datos (catálogos) y no escritas a mano en el código (ADR-0006)?
- [ ] ¿Quedaron escritas las alternativas descartadas y el porqué?

## 6. Límites

- SSoT mejora la *exploración*; no reemplaza las pruebas, el modelo de datos ni la revisión humana.
- Funciona mejor en modelos con buen razonamiento; en modelos pequeños el efecto baja.
- Diversidad sin criterio es ruido: siempre se cierra con la sección 3.
