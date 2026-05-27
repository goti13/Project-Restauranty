# ─── React Frontend ───────────────────────────────────────────────────────────
# Stage 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .

# REACT_APP_SERVER_URL is injected at build time via --build-arg
ARG REACT_APP_SERVER_URL=http://localhost:80
ENV REACT_APP_SERVER_URL=$REACT_APP_SERVER_URL

RUN npm run build

# Stage 2: Serve with nginx
FROM nginx:stable-alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built React app
COPY --from=builder /app/build /usr/share/nginx/html

# nginx config: serve SPA and forward /api/* to backend (handled by Ingress/HAProxy)
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
