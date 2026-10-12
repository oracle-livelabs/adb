import test from 'node:test';
import assert from 'node:assert/strict';
import { buildGraphPages } from '../src/graphPages.js';
import { parseNoticeTemplate, validatePersonalizedNotice } from '../src/noticeTemplate.js';

test('graph pages keep the full shortest path for nodes on later pages', () => {
  const batch = { id: 'B-482', labels: ['batch'] };
  const store = { id: 'STORE-101', labels: ['store'] };
  const firstCustomer = { id: 'C-1', labels: ['customer'] };
  const secondCustomer = { id: 'C-2', labels: ['customer'] };
  const vertices = [batch, store, firstCustomer, secondCustomer];
  const edges = [
    { id: 'e1', source: 'B-482', target: 'STORE-101' },
    { id: 'e2', source: 'STORE-101', target: 'C-1' },
    { id: 'e3', source: 'STORE-101', target: 'C-2' }
  ];

  const result = buildGraphPages(vertices, edges, 3, batch);
  const laterPage = result.pages[1];
  assert.deepEqual(laterPage.focusVertices.map((vertex) => vertex.id), ['C-2']);
  assert.deepEqual(laterPage.vertices.map((vertex) => vertex.id), ['B-482', 'STORE-101', 'C-2']);
  assert.deepEqual(laterPage.edges.map((edge) => edge.id), ['e1', 'e3']);
});

test('notice parsing unwraps fenced JSON inside the campaign response', () => {
  const wrapped = JSON.stringify({
    source: 'SELECT_AI_AGENT',
    template: '```json\n{"subject":"Safety notice","body":"Stop using {{product_name}} in batch {{batch_id}}.","refundSteps":"{{refund_steps}}"}\n```'
  });
  const notice = parseNoticeTemplate(wrapped);
  assert.equal(notice.valid, true);
  assert.equal(notice.subject, 'Safety notice');
  assert.equal(notice.source, 'SELECT_AI_AGENT');
});

test('fallback notice keeps its diagnostic visible to the application', () => {
  const fallback = parseNoticeTemplate(JSON.stringify({
    source: 'SAFE_FALLBACK',
    diagnostic: 'The campaign agent call failed with SQL code -20001.',
    template: JSON.stringify({ subject: 'Subject', body: 'Body', refundSteps: 'Steps' })
  }));
  assert.equal(fallback.usedFallback, true);
  assert.match(fallback.diagnostic, /SQL code -20001/);
});

test('malformed notices produce a visible safe fallback and fail validation', () => {
  const notice = parseNoticeTemplate('```json\nnot json\n```');
  assert.equal(notice.valid, false);
  assert.equal(notice.usedFallback, true);
  assert.match(notice.body, /{{refund_steps}}/);
});

test('personalized validation rejects unresolved placeholders and missing facts', () => {
  const template = parseNoticeTemplate(JSON.stringify({
    subject: 'Safety notice for {{product_name}}',
    body: 'Hello {{customer_name}}',
    refundSteps: '{{refund_steps}}'
  }));
  const result = validatePersonalizedNotice({
    template,
    subject: 'Safety notice for Cooker',
    body: 'Hello Amy',
    refundSteps: 'Stop using the item.',
    recipient: { customerName: 'Amy', productName: 'Cooker', sku: 'SKU-1', purchaseId: 81, quantity: 2, refundAmount: 259.98 },
    product: { product: 'Cooker', sku: 'SKU-1' },
    batchId: 'B-482',
    approvedRefundSteps: 'Stop using the item.'
  });
  assert.equal(result.valid, false);
  assert.ok(result.errors.some((error) => error.includes('purchase ID 81')));
});
