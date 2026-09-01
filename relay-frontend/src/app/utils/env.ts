/**
 * Runtime env — single source is .env
 * Browser has no OS env, so docker-entrypoint.sh writes public/env.js at container start:
 *   window.__env = { keycloakUrl, frontendUrl, ... }
 * For `ng serve` locally, public/env.js defaults are used (no build needed).
 * This file is the ONLY place frontend reads env — change .env, restart frontend, done.
 */
declare global {
  interface Window {
    __env?: Record<string, string>;
  }
}

function readEnv(key: string, fallback: string): string {
  return window.__env?.[key] ?? fallback;
}

export const env = {
  keycloakUrl: readEnv('keycloakUrl', 'http://localhost:9090'),
  keycloakRealm: readEnv('keycloakRealm', 'relay'),
  keycloakClientId: readEnv('keycloakClientId', 'relay-frontend'),
  frontendUrl: readEnv('frontendUrl', 'http://localhost:4200'),
  apiUrl: readEnv('apiUrl', 'http://localhost:8080'),
} as const;
