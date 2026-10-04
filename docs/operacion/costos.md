# Costos de infraestructura (RNF-COS-01)

Meta: menos de **$150.000 COP al mes** hasta 30 comercios. Cálculo con US$1 = $4.200 COP (revisar la tasa cuando se renueve).

| Servicio | Plan | US$/mes | COP/mes |
| --- | --- | --- | --- |
| Render, API producción | Starter | 7 | 29.400 |
| Render, API staging | Free (se duerme sin tráfico) | 0 | 0 |
| Neon, PostgreSQL (staging y producción como ramas) | Free al iniciar; Launch al pasar de 0,5 GB o necesitar más historial | 0 a 19 | 0 a 79.800 |
| Vercel, panel | Hobby | 0 | 0 |
| Sentry, errores y uptime | Developer (gratis) | 0 | 0 |
| GitHub Actions y artefactos de copias | incluido en la cuenta | 0 | 0 |
| **Total** | | **7 a 26** | **29.400 a 109.200** |

## Cuándo revisar

- **Vercel Hobby** es para uso no comercial: al cobrar a los comercios, pasar a Pro (US$20) y el total sube a unos $193.000 COP. Alternativa dentro de la meta: servir el panel desde Render como sitio estático o servicio Node (US$7).
- **GitHub Actions:** en un repositorio privado, el plan gratuito trae 2.000 minutos al mes. El CI completo usa unos 15 minutos por ejecución y la vigilancia horaria unos 720 al mes; si se acercan al límite, bajar la vigilancia a cada 3 horas (Sentry Uptime sigue cada minuto).
- **Neon:** vigilar el almacenamiento en el panel; con 30 comercios el modelo cabe holgado en el plan gratuito, pero el historial de restauración es corto.
