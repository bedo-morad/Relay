#!/bin/sh
set -e
# Generate runtime env.js from container env (single source = .env -> docker-compose -> container env)
# No rebuild needed — change .env and restart frontend container.
cat > /usr/share/nginx/html/env.js <<EOF
window.__env = window.__env || {};
window.__env.keycloakUrl = "${KEYCLOAK_FRONTEND_URL:-http://localhost:9090}";
window.__env.keycloakRealm = "${KEYCLOAK_REALM:-relay}";
window.__env.keycloakClientId = "${KEYCLOAK_CLIENT_ID:-relay-frontend}";
window.__env.frontendUrl = "${FRONTEND_URL:-http://localhost:4200}";
window.__env.apiUrl = "${API_URL:-http://localhost:8080}";
EOF
echo "[entrypoint] wrote /usr/share/nginx/html/env.js from env"
exec nginx -g 'daemon off;'
