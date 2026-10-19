const { traceContext } = require('./middleware');
const { log } = require('./logger');

const metrics = {
  document_generation_requests_total: 0,
  document_generation_request_duration_seconds: [],
  document_generation_worker_queue_size: 0,
};

function simulateRequest(headers = {}) {
  const req = { headers };
  traceContext(req, {}, () => {});

  const startedAt = Date.now();
  metrics.document_generation_requests_total += 1;
  metrics.document_generation_worker_queue_size += 1;

  const outboundHeaders = {
    traceparent: `00-${req.traceId}-00f067aa0ba902b7-01`,
  };
  log('INFO', req.traceId, 'document.summary.published', 'Evento PostConsultationSummaryGenerated publicado');

  metrics.document_generation_worker_queue_size -= 1;
  metrics.document_generation_request_duration_seconds.push((Date.now() - startedAt) / 1000);
  return { traceId: req.traceId, outboundHeaders, metrics };
}

if (require.main === module) {
  const result = simulateRequest({});
  process.stdout.write(`${JSON.stringify({
    sent_trace_id: result.outboundHeaders.traceparent.split('-')[1],
    metrics: result.metrics,
  })}\n`);
}

module.exports = { simulateRequest };
