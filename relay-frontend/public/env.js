// This file is REPLACED at container startup by docker-entrypoint.sh from .env
// Local dev (ng serve) uses these defaults — no build needed.
window.__env = window.__env || {};
window.__env.keycloakUrl = "http://localhost:9090";
window.__env.keycloakRealm = "relay";
window.__env.keycloakClientId = "relay-frontend";
window.__env.frontendUrl = "http://localhost:4200";
window.__env.apiUrl = "http://localhost:8080";
