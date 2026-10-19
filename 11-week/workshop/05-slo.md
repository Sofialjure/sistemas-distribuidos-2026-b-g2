# SLO y Error Budget — Generate Consultation Document

**Servicio principal:** `document-generation-api`  
**Ventana de evaluación:** 30 días  
**Dependencias:** `api-gateway`, PostgreSQL (`document-generation-db`), RabbitMQ y MinIO.

## Objetivos y SLI

| SLO | Objetivo en 30 días | SLI y PromQL |
|---|---:|---|
| Availability | 99.5% de las peticiones completan sin error | `1 - (sum(increase(document_generation_requests_total{status="error"}[30d])) / sum(increase(document_generation_requests_total[30d])))` |
| Latency | 95% de las peticiones tardan menos de 2 segundos | `sum(increase(document_generation_request_duration_seconds_bucket{le="2"}[30d])) / sum(increase(document_generation_request_duration_seconds_count[30d]))` |
| Durability | 99.9% de los PDFs se guardan correctamente en MinIO | `sum(increase(document_generation_pdf_uploads_total{status="success"}[30d])) / sum(increase(document_generation_pdf_uploads_total[30d]))` |

El contador de peticiones debe incluir los resultados `success` y `error`. Para durabilidad, se cuenta como correcto un PDF confirmado por MinIO y persistido con estado `AVAILABLE`.

## Tráfico y presupuesto

Con un tráfico estimado de **1,000 documentos por día**, el volumen esperado en 30 días es:

```text
1,000 documentos/día × 30 días = 30,000 documentos/mes
```

Para Availability de 99.5%, el presupuesto de error es 0.5%:

```text
30,000 peticiones × 0.005 = 150 peticiones fallidas al mes
30 días × 24 horas × 60 minutos × 0.005 = 216 minutos de caída total equivalente
```

Las 150 peticiones son el presupuesto basado en peticiones; 216 minutos representan su equivalente si el servicio tuviera una caída total. No son unidades intercambiables cuando solo una parte del tráfico falla.

## Política de Error Budget

- **50% consumido:** pausar la incorporación de nuevas features y priorizar la reducción de errores.
- **75% consumido:** code freeze para cambios funcionales; permitir solo correcciones y trabajo de confiabilidad.
- **100% consumido:** todo el equipo prioriza resiliencia hasta recuperar presupuesto en la ventana acordada.
