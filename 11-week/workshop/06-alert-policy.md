# Política de alertas — Generate Consultation Document

## Alertas de burn rate

- **Rápida:** un burn rate de 14.4 durante una ventana de 1 hora consume `14.4 × (1 / 720) = 2%` del Error Budget de 30 días. Se confirma durante 5 minutos y tiene severidad `critical`.
- **Lenta:** un burn rate de 6 durante una ventana de 6 horas consume `6 × (6 / 720) = 5%` del Error Budget de 30 días. Se confirma durante 30 minutos y tiene severidad `warning`.

La alerta rápida detecta una degradación intensa que requiere respuesta inmediata. La lenta detecta un deterioro sostenido antes de que agote el presupuesto.

## Alertas de causa que no se crearán

- **CPU > 80%:** por sí sola no indica si el paciente puede generar y obtener su PDF; puede alertar sin impacto visible o no alertar ante una dependencia lenta.
- **Memoria > 90%:** el porcentaje aislado no mide el resultado de la generación, la duración de la petición ni la disponibilidad del PDF.

Se alertará sobre SLI y burn rate orientados al resultado de usuario. Las métricas de recursos sirven para diagnóstico y capacidad, no como sustituto de la experiencia de generación del PDF.
