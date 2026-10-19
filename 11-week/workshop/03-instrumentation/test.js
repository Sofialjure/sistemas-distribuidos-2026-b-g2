const assert = require('node:assert/strict');
const { simulateRequest } = require('./app');

const receivedTraceId = '4bf92f3577b34da6a3ce929d0e0e4736';
const result = simulateRequest({
  traceparent: `00-${receivedTraceId}-00f067aa0ba902b7-01`,
});
const sentTraceId = result.outboundHeaders.traceparent.split('-')[1];

assert.equal(result.traceId, receivedTraceId);
assert.equal(sentTraceId, receivedTraceId);
process.stdout.write('trace_id recibido y enviado coinciden\n');
