# ─── Restauranty – GitHub Actions Secrets Setup ──────────────────────────────
# Run these commands once to set up the secrets needed for CI/CD.
# Then add each value to GitHub → Settings → Secrets → Actions.
# ─────────────────────────────────────────────────────────────────────────────
 
# ── 1. AZURE_CREDENTIALS ──────────────────────────────────────────────────────
# Create a service principal for GitHub Actions to access AKS:
az ad sp create-for-rbac \
  --name "restauranty-github-actions" \
  --role contributor \
  --scopes /subscriptions/daf9c53c-7096-4293-9bb1-f7ad8263db1a/resourceGroups/geraldAKSGroup \
  --sdk-auth
 
# Copy the entire JSON output and add it as GitHub secret: AZURE_CREDENTIALS
 
# ── 2. DOCKER_PASSWORD ────────────────────────────────────────────────────────
# Use your Docker Hub password or a Personal Access Token (PAT):
# → https://app.docker.com/settings/personal-access-tokens
# Add as GitHub secret: DOCKER_PASSWORD
 
# ── 3. App secrets (same values as your secrets.env) ─────────────────────────
# Add each as a GitHub secret:
#
# Secret Name       Value
# ──────────────    ─────────────────────────────────────
# APP_SECRET        MySecret1!
# MONGODB_URI       mongodb://mongo-service:27017/restauranty
# CLOUD_NAME        da25jncb1
# CLOUD_API_KEY     768966861377855
# CLOUD_API_SECRET  VQYM_Y--BE9fw3gzlxh5tZO0zvI
# AZURE_CREDENTIALS JSON 
# DOCKER_PASSWORD   Docker Hub password/PAT
# ── How to add secrets to GitHub ─────────────────────────────────────────────
# 1. Go to your GitHub repo
# 2. Settings → Secrets and variables → Actions
# 3. Click "New repository secret"
# 4. Add each secret above by name and value
