const SERVICE = process.env.SERVICE_NAME || 'appointment-scheduling-api';

function log(level, traceId, event, message) {
  const record = {
    timestamp: new Date().toISOString(),
    level,
    service: SERVICE,
    trace_id: traceId,
    event,
    message,
  };

  process.stdout.write(`${JSON.stringify(record)}\n`);
}

module.exports = { log };
