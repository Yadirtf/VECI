# VECI · Arquitectura

Esta carpeta guarda la base técnica acordada de VECI: el modelo de datos y las decisiones de arquitectura (HU-00-03) y los resultados de las pruebas de concepto (HU-00-04). Todo cambio a estas piezas entra por PR, igual que el código.

| Carpeta | Qué contiene |
| --- | --- |
| [modelo-datos/](modelo-datos/README.md) | Modelo relacional de PostgreSQL: principios, diagramas entidad-relación por módulo, diccionario de datos, escalabilidad y el DDL de referencia validado con pruebas. |
| [poc/](poc/hu-00-04-escaneo-offline.md) | Resultados y código de referencia de las pruebas de concepto de la Fase 0 (HU-00-04: escaneo offline). |
| [arquitectura-limpia.md](arquitectura-limpia.md) | Cómo se organiza el código en capas en la API, el panel y la app, y qué revisa el CI (HU-01-10). |
| [adr/](adr/README.md) | Registro de decisiones de arquitectura: qué se decidió, por qué, qué se descartó y qué consecuencias tiene. |

Documentos relacionados: [requerimientos](../requerimientos-y-recomendaciones-tecnologicas.md) (secciones 5.2 y 5.3) y [backlog](../backlog.md).
