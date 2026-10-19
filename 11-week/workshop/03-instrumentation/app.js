const { traceContext } = require('./middleware');
const { log } = require('./logger');

const metrics = {
  document_generation_requests_total: { success: 0, error: 0 },
  document_generation_request_duration_seconds_sum: 0,
  document_generation_request_duration_seconds_count: 0,
  document_generation_worker_queue_size: 0,
};

function simulateRequest(headers = {}) {
  const req = { headers };
  traceContext(req, {}, () => {});

  metrics.document_generation_requests_total.success += 1;
  metrics.document_generation_worker_queue_size += 1;

  const outboundHeaders = {
    traceparent: `00-${req.traceId}-00f067aa0ba902b7-01`,
  };
  log('INFO', req.traceId, 'document.summary.published', 'Evento PostConsultationSummaryGenerated publicado');

  metrics.document_generation_worker_queue_size -= 1;
  metrics.document_generation_request_duration_seconds_sum += 1.2;
  metrics.document_generation_request_duration_seconds_count += 1;
  return { traceId: req.traceId, outboundHeaders, metrics };
}

function metricsEndpoint(path) {
  if (path !== '/metrics') return null;

  return [
    '# HELP document_generation_requests_total Total document generation requests by result.',
    '# TYPE document_generation_requests_total counter',
    `document_generation_requests_total{status="success"} ${metrics.document_generation_requests_total.success}`,
    `document_generation_requests_total{status="error"} ${metrics.document_generation_requests_total.error}`,
    '# HELP document_generation_request_duration_seconds Duration of document generation requests in seconds.',
    '# TYPE document_generation_request_duration_seconds histogram',
    `document_generation_request_duration_seconds_sum ${metrics.document_generation_request_duration_seconds_sum}`,
    `document_generation_request_duration_seconds_count ${metrics.document_generation_request_duration_seconds_count}`,
    '# HELP document_generation_worker_queue_size Number of documents waiting for a worker.',
    '# TYPE document_generation_worker_queue_size gauge',
    `document_generation_worker_queue_size ${metrics.document_generation_worker_queue_size}`,
  ].join('\n') + '\n';
}

if (require.main === module) {
  simulateRequest({});
  process.stdout.write(metricsEndpoint('/metrics'));
}

module.exports = { metricsEndpoint, simulateRequest };
