const safeNotice = {
  subject: 'Important safety notice for {{product_name}}',
  body: 'Hello {{customer_name}},\n\nWe are contacting you about {{product_name}} ({{sku}}), batch {{batch_id}}. Please stop using the item and follow these steps:\n{{refund_steps}}\n\nYour approved refund amount is {{refund_amount}}. Our recall response team will help complete the refund.',
  refundSteps: '{{refund_steps}}'
};

function jsonCandidates(value) {
  const text = String(value || '').trim();
  if (!text) return [];
  const unfenced = text
    .replace(/^```(?:json)?\s*/i, '')
    .replace(/\s*```$/, '')
    .trim();
  const start = unfenced.indexOf('{');
  const end = unfenced.lastIndexOf('}');
  return [...new Set([
    text,
    unfenced,
    start >= 0 && end > start ? unfenced.slice(start, end + 1) : ''
  ].filter(Boolean))];
}

function parseObject(value) {
  if (value && typeof value === 'object' && !Array.isArray(value)) return value;
  for (const candidate of jsonCandidates(value)) {
    try {
      const parsed = JSON.parse(candidate);
      if (parsed && typeof parsed === 'object' && !Array.isArray(parsed)) return parsed;
    } catch {
      // Try the next acceptable wrapper around the JSON response.
    }
  }
  return null;
}

export function parseNoticeTemplate(value) {
  let parsed = parseObject(value);
  let source = parsed?.source || 'SELECT_AI_AGENT';
  let diagnostic = parsed?.diagnostic || null;

  if (parsed && !('subject' in parsed) && 'template' in parsed) {
    const wrapper = parsed;
    parsed = parseObject(parsed.template);
    diagnostic ||= wrapper.diagnostic || null;
  }

  const errors = ['subject', 'body', 'refundSteps']
    .filter((field) => typeof parsed?.[field] !== 'string' || !parsed[field].trim())
    .map((field) => `The notice is missing a usable ${field} field.`);

  if (errors.length) {
    return {
      ...safeNotice,
      source,
      diagnostic,
      valid: false,
      usedFallback: true,
      errors: errors.length ? errors : ['The notice response was not valid JSON.']
    };
  }

  return {
    subject: parsed.subject.trim(),
    body: parsed.body.trim(),
    refundSteps: parsed.refundSteps.trim(),
    source,
    diagnostic,
    valid: true,
    usedFallback: source === 'SAFE_FALLBACK',
    errors: []
  };
}

export function validatePersonalizedNotice({ template, subject, body, refundSteps, recipient, product, batchId, approvedRefundSteps }) {
  const errors = [...(template?.errors || [])];
  if (!template?.valid) errors.push('Regenerate the notice before approval.');

  const rendered = `${subject || ''}\n${body || ''}\n${refundSteps || ''}`;
  if (/\{\{\s*[\w.-]+\s*\}\}/.test(rendered)) {
    errors.push('The personalized notice still contains unresolved placeholders.');
  }

  const productName = recipient?.productName || product?.product;
  const sku = recipient?.sku || product?.sku;
  const requiredFacts = [
    ['customer name', recipient?.customerName],
    ['product name', productName],
    ['SKU', sku],
    ['batch ID', batchId],
    ['purchase ID', recipient?.purchaseId],
    ['quantity', recipient?.quantity],
    ['approved refund amount', Number.isFinite(Number(recipient?.refundAmount)) ? `$${Number(recipient.refundAmount).toFixed(2)}` : null]
  ].filter(([, fact]) => fact !== undefined && fact !== null && String(fact).trim());
  const normalized = rendered.toLocaleLowerCase();
  requiredFacts.forEach(([label, fact]) => {
    if (!normalized.includes(String(fact).toLocaleLowerCase())) {
      errors.push(`The personalized notice is missing the ${label} ${fact}.`);
    }
  });

  if (approvedRefundSteps && String(refundSteps || '').trim() !== approvedRefundSteps.trim()) {
    errors.push('The notice refund steps do not match the approved campaign policy.');
  }

  return { valid: errors.length === 0, errors };
}
