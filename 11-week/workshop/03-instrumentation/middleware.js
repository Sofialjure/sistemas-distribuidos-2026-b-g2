const { randomUUID } = require('node:crypto');

function traceContext(req, res, next) {
  const traceparent = req.headers?.traceparent;
  const match = typeof traceparent === 'string'
    ? /^\d{2}-([0-9a-f]{32})-[0-9a-f]{16}-[0-9a-f]{2}$/i.exec(traceparent)
    : null;

  req.traceId = match ? match[1].toLowerCase() : randomUUID().replaceAll('-', '');
  next();
}

module.exports = { traceContext };
