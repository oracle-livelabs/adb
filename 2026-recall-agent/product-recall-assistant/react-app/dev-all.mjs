import { spawn } from 'node:child_process';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.dirname(fileURLToPath(import.meta.url));
const server = spawn(process.execPath, ['server.mjs'], {
  cwd: root,
  env: { ...process.env, VITE_MIDDLEWARE: 'true' },
  stdio: 'inherit'
});

function stop() {
  server.kill('SIGTERM');
}

process.on('SIGINT', stop);
process.on('SIGTERM', stop);
server.on('exit', (code) => process.exit(code || 0));
