#!/bin/bash
# ─── Restauranty – Build & Push to Docker Hub ────────────────────────────────
# Usage:
#   chmod +x build-and-push.sh
#   ./build-and-push.sh                                       # tag: latest,  API: http://localhost:80
#   ./build-and-push.sh v1.0.0                               # tag: v1.0.0,  API: http://localhost:80
#   ./build-and-push.sh v1.0.0 http://api.yourdomain.com     # tag: v1.0.0,  API: your production URL
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

DOCKER_USER="otigerald"
TAG="${1:-latest}"
REACT_APP_SERVER_URL="${2:-http://localhost:80}"

IMAGES=(
  "restauranty-auth:./backend/auth"
  "restauranty-discounts:./backend/discounts"
  "restauranty-items:./backend/items"
  "restauranty-client:./client"
)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Restauranty – Docker Build & Push"
echo " User : $DOCKER_USER"
echo " Tag  : $TAG"
echo " API  : $REACT_APP_SERVER_URL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ── Login ─────────────────────────────────────────────────────────────────────
echo ""
echo "▶ Logging in to Docker Hub..."
docker login --username "$DOCKER_USER"

# ── Build & Push each image ───────────────────────────────────────────────────
for ENTRY in "${IMAGES[@]}"; do
  IMAGE_NAME="${ENTRY%%:*}"
  CONTEXT="${ENTRY##*:}"
  FULL_TAG="$DOCKER_USER/$IMAGE_NAME:$TAG"

  echo ""
  echo "▶ Building $FULL_TAG from $CONTEXT ..."

  if [ "$IMAGE_NAME" = "restauranty-client" ]; then
    # React needs the API URL baked in at build time
    docker build \
      --build-arg REACT_APP_SERVER_URL="$REACT_APP_SERVER_URL" \
      -t "$FULL_TAG" \
      "$CONTEXT"
  else
    docker build \
      -t "$FULL_TAG" \
      "$CONTEXT"
  fi

  echo "▶ Pushing $FULL_TAG ..."
  docker push "$FULL_TAG"

  echo "✔ Done: $FULL_TAG"
done

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " All images pushed to Docker Hub:"
for ENTRY in "${IMAGES[@]}"; do
  IMAGE_NAME="${ENTRY%%:*}"
  echo "  docker.io/$DOCKER_USER/$IMAGE_NAME:$TAG"
done
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
