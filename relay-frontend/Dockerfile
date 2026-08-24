# Build stage: compile the Angular app
FROM node:22-alpine AS build
WORKDIR /app

# Cache dependencies: manifests first, source later
COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# Run stage: nginx serves the static SPA build
FROM nginx:1.27-alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/relay-frontend/browser /usr/share/nginx/html

EXPOSE 80
