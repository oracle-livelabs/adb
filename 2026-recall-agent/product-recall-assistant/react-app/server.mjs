import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

import dotenv from 'dotenv';
import express from 'express';

dotenv.config();

const require = createRequire(import.meta.url);
const oracledb = require('oracledb');
const __dirname = path.dirname(fileURLToPath(import.meta.url));

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;
oracledb.fetchAsString = [oracledb.CLOB];

const app = express();
const port = Number(process.env.PORT || 3001);
const useViteMiddleware = process.env.VITE_MIDDLEWARE === 'true';
const connectString = process.env.ORACLE_CONNECT_STRING;
const oracleConfigDir = process.env.ORACLE_CONFIG_DIR;
const oracleWalletLocation = process.env.ORACLE_WALLET_LOCATION || oracleConfigDir;
const oracleWalletPassword = process.env.ORACLE_WALLET_PASSWORD;
const hasConfiguredConnectString = Boolean(
  connectString && !/your-adb-host|your-service-name/i.test(connectString)
);
const cookieName = 'recall_session';
const sessionTtlMs = 30 * 60 * 1000;
const sessions = new Map();
const allowedPersonas = new Set([
  'STORE_101_USER',
  'REGION_NE_USER',
  'RECALL_LEAD_USER'
]);

app.use(express.json({ limit: '32kb' }));

function parseCookies(header = '') {
  return Object.fromEntries(header.split(';').filter(Boolean).map((part) => {
    const index = part.indexOf('=');
    return [part.slice(0, index).trim(), decodeURIComponent(part.slice(index + 1).trim())];
  }));
}

function setSessionCookie(res, token) {
  const secure = process.env.COOKIE_SECURE === 'true' ? '; Secure' : '';
  res.setHeader(
    'Set-Cookie',
    `${cookieName}=${encodeURIComponent(token)}; HttpOnly; SameSite=Lax; Path=/; Max-Age=${sessionTtlMs / 1000}${secure}`
  );
}

function clearSessionCookie(res) {
  res.setHeader('Set-Cookie', `${cookieName}=; HttpOnly; SameSite=Lax; Path=/; Max-Age=0`);
}

function getToken(req) {
  return parseCookies(req.headers.cookie)[cookieName];
}

function getSession(req) {
  const token = getToken(req);
  const session = token ? sessions.get(token) : null;
  if (!session) return null;
  if (Date.now() - session.lastSeen > sessionTtlMs) {
    sessions.delete(token);
    session.connection.close().catch(() => {});
    return null;
  }
  session.lastSeen = Date.now();
  return { token, ...session };
}

function requireSession(req, res, next) {
  const session = getSession(req);
  if (!session) return res.status(401).json({ error: 'Sign in with a recall persona first.' });
  req.recallSession = session;
  return next();
}

function getOracleConnectionOptions(username, password) {
  const options = { user: username, password, connectString };
  if (oracleConfigDir) options.configDir = oracleConfigDir;
  if (oracleWalletLocation) options.walletLocation = oracleWalletLocation;
  if (oracleWalletPassword) options.walletPassword = oracleWalletPassword;
  return options;
}

function explainConnectionError(error) {
  if (error?.code === 'NJS-530') {
    return 'The database host or service cannot be resolved. ORACLE_CONNECT_STRING must be an Oracle Net database connect string or wallet TNS alias, not an HTTPS ORDS URL. Check the ADB host, service name, wallet/config paths, and network access, then restart the Node API.';
  }
  if (error?.message?.includes('ORA-00904') && error.message.includes('RECALL_REACT_API')) {
    return 'RECALL_REACT_API.CURRENT_IDENTITY is not available to this database session. Connect as RECALL_OWNER and run files/05-prepare-react-app.sql, confirm the package is VALID, then restart the React API.';
  }
  return error?.message || 'Database login failed.';
}

async function readJsonQuery(connection, sql, binds = {}) {
  const result = await connection.execute(sql, binds);
  const row = result.rows?.[0];
  const value = row ? Object.values(row)[0] : null;
  if (value === null || value === undefined) return null;
  if (typeof value === 'string') return JSON.parse(value);
  if (typeof value === 'object' && value.on) {
    const chunks = [];
    for await (const chunk of value) chunks.push(chunk);
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
  }
  return value;
}

async function readQueryText(connection, sql, binds = {}) {
  const result = await connection.execute(sql, binds);
  const row = result.rows?.[0];
  const value = row ? Object.values(row)[0] : null;
  if (value === null || value === undefined) return null;
  if (typeof value === 'string') return value;
  if (typeof value === 'object' && value.on) {
    const chunks = [];
    for await (const chunk of value) chunks.push(chunk);
    return Buffer.concat(chunks).toString('utf8');
  }
  return String(value);
}

async function readJsonValue(value) {
  if (value === null || value === undefined) return null;
  if (typeof value === 'string') return JSON.parse(value);
  if (typeof value === 'object' && value.on) {
    const chunks = [];
    for await (const chunk of value) chunks.push(chunk);
    return JSON.parse(Buffer.concat(chunks).toString('utf8'));
  }
  return value;
}

function mergeRecallGraphs(shared, downstream) {
  if (!shared || shared.error) return shared;
  if (!downstream || downstream.error) return shared;
  return {
    ...shared,
    scope: 'Shared supplier trace plus DDS-filtered downstream exposure',
    authorizedStoreCount: downstream.authorizedStoreCount,
    authorizedCustomerCount: downstream.authorizedCustomerCount,
    vertices: [...(shared.vertices || []), ...(downstream.vertices || [])],
    edges: [...(shared.edges || []), ...(downstream.edges || [])]
  };
}

async function getIdentity(connection) {
  const result = await connection.execute(
    `begin :payload := recall_react_api.current_identity; end;`,
    { payload: { dir: oracledb.BIND_OUT, type: oracledb.CLOB } }
  );
  return readJsonValue(result.outBinds.payload);
}

async function getRecallBundle(connection, batchId) {
  const binds = { batchId: String(batchId).toUpperCase() };
  // A single Oracle connection is held for the browser session, so execute
  // these package calls sequentially rather than overlapping round trips.
  const identity = await getIdentity(connection);
  const product = await readJsonQuery(
    connection,
    `select recall_react_api.product_context(:batchId) as payload`,
    binds
  );
  const context = await readJsonQuery(
    connection,
    `select recall_secure_api.get_secured_context(:batchId) as payload`,
    binds
  );
  const stores = await readJsonQuery(
    connection,
    `select recall_react_api.secured_stores(:batchId) as payload`,
    binds
  );
  const sharedGraph = await readJsonQuery(
    connection,
    `select recall_graph_api.context(:batchId) as payload`,
    binds
  );
  const downstreamGraph = await readJsonQuery(
    connection,
    `select recall_react_api.secured_graph(:batchId) as payload`,
    binds
  );
  return { identity, product, context, stores, graph: mergeRecallGraphs(sharedGraph, downstreamGraph) };
}

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, databaseConfigured: hasConfiguredConnectString });
});

app.post('/api/auth/login', async (req, res) => {
  const username = String(req.body?.username || '').toUpperCase();
  const password = String(req.body?.password || '');
  if (!allowedPersonas.has(username) || !password) {
    return res.status(400).json({ error: 'Choose a recall persona and enter its lab password.' });
  }
  if (!hasConfiguredConnectString) {
    return res.status(503).json({ error: 'Replace the ORACLE_CONNECT_STRING template value in .env with the actual Autonomous Database TLS connection string or wallet TNS alias, then restart the Node API.' });
  }

  let connection;
  try {
    connection = await oracledb.getConnection(getOracleConnectionOptions(username, password));
    const identity = await getIdentity(connection);
    if (identity?.username !== username) throw new Error('The database session did not establish the selected end-user context.');
    const token = crypto.randomBytes(32).toString('hex');
    sessions.set(token, { connection, username, identity, lastSeen: Date.now() });
    setSessionCookie(res, token);
    return res.json({ identity });
  } catch (error) {
    if (connection) await connection.close().catch(() => {});
    return res.status(401).json({ error: explainConnectionError(error) });
  }
});

app.post('/api/auth/logout', async (req, res) => {
  const token = getToken(req);
  const session = token ? sessions.get(token) : null;
  if (session) await session.connection.close().catch(() => {});
  if (token) sessions.delete(token);
  clearSessionCookie(res);
  return res.status(204).end();
});

app.get('/api/session', requireSession, (req, res) => {
  res.json({ identity: { username: req.recallSession.username } });
});

app.get('/api/recall/:batchId', requireSession, async (req, res) => {
  try {
    res.json(await getRecallBundle(req.recallSession.connection, req.params.batchId));
  } catch (error) {
    res.status(500).json({ error: error.message || 'Unable to load secured recall data.' });
  }
});

app.post('/api/vector-search', requireSession, async (req, res) => {
  const query = String(req.body?.query || '').trim();
  const batchId = String(req.body?.batchId || 'B-482').toUpperCase();
  if (!query) return res.status(400).json({ error: 'Enter a complaint symptom or evidence phrase.' });
  try {
    const payload = await readJsonQuery(
      req.recallSession.connection,
      `select recall_react_api.search_vector_evidence(:batchId, :query) as payload`,
      { batchId, query: query.slice(0, 1000) }
    );
    res.json(payload);
  } catch (error) {
    res.status(500).json({ error: error.message || 'The secured vector search failed.' });
  }
});

app.post('/api/agent', requireSession, async (req, res) => {
  const question = String(req.body?.question || '').trim();
  const batchId = String(req.body?.batchId || 'B-482').toUpperCase();
  if (!question) return res.status(400).json({ error: 'Enter a recall question.' });
  try {
    // Keep the call on the authenticated DDS session. RECALL_REACT_API is
    // invoker-rights and materializes the visible context before it calls the
    // owner-owned definer-rights agent bridge.
    const answer = await readQueryText(
      req.recallSession.connection,
      `select recall_react_api.ask_agent(:batchId, :question) as payload`,
      { batchId, question: question.slice(0, 1000) }
    );
    res.json({ answer });
  } catch (error) {
    res.status(500).json({ error: error.message || 'The secured agent call failed.' });
  }
});

setInterval(() => {
  for (const [token, session] of sessions) {
    if (Date.now() - session.lastSeen > sessionTtlMs) {
      sessions.delete(token);
      session.connection.close().catch(() => {});
    }
  }
}, 60_000).unref();

const distPath = path.join(__dirname, 'dist');
let viteServer;

if (useViteMiddleware) {
  const { createServer: createViteServer } = await import('vite');
  viteServer = await createViteServer({
    root: __dirname,
    server: { middlewareMode: true, hmr: false },
    appType: 'spa'
  });
  app.use(viteServer.middlewares);
} else if (fs.existsSync(distPath)) {
  app.use(express.static(distPath));
  app.use((req, res, next) => {
    if (req.method === 'GET') return res.sendFile(path.join(distPath, 'index.html'));
    return next();
  });
}

const httpServer = app.listen(port, () => {
  console.log(`Recall Node API and React app listening on http://localhost:${port}`);
});

async function shutdown() {
  if (viteServer) await viteServer.close();
  httpServer.close();
}

process.on('SIGINT', shutdown);
process.on('SIGTERM', shutdown);
