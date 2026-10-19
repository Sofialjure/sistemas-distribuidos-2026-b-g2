const SERVICE = process.env.SERVICE_NAME || 'document-generation-api';
const VERSION = process.env.SERVICE_VERSION || '1.0.0';
const ENVIRONMENT = process.env.NODE_ENV || 'dev';

function log(level, traceId, event, message, options = {}) {
  const record = {
    timestamp: new Date().toISOString(),
    level,
    service: SERVICE,
    version: VERSION,
    environment: ENVIRONMENT,
    trace_id: traceId,
    span_id: options.spanId || '0000000000000001',
    correlation_id: options.correlationId || traceId,
    event,
    message,
    duration_ms: options.durationMs ?? 0,
  };

  process.stdout.write(`${JSON.stringify(record)}\n`);
}

module.exports = { log };
