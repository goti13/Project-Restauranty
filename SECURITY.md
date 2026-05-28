# Security & Compliance

This document outlines the security measures, secret management practices, network policies, TLS configuration, and compliance considerations for the Restauranty project.

---

## 1. Secret Management

### Local Development
Secrets are stored in `.env` files per microservice (`backend/auth/.env`, `backend/discounts/.env`, `backend/items/.env`) and a root-level `secrets.env` file for Kubernetes deployments.

All secret files are listed in `.gitignore` and are **never committed to the repository**. A `secrets.env.example` template with empty values is committed instead:

```
secrets.env              # git-ignored — real values
secrets.env.example      # committed — empty template
backend/auth/.env        # git-ignored
backend/discounts/.env   # git-ignored
backend/items/.env       # git-ignored
client/.env              # git-ignored
```

### Kubernetes
Secrets are injected into the cluster at deploy time using `kubectl create secret` from the local `secrets.env` file:

```bash
kubectl create secret generic restauranty-secrets \
  --from-env-file=secrets.env \
  --namespace=restauranty \
  --dry-run=client -o yaml | kubectl apply -f -
```

Values are never written to disk or committed to the repository. Each pod references the secret via `secretKeyRef` — values are injected as environment variables at runtime.

### CI/CD Pipeline
All secrets are stored as **GitHub Actions Secrets** and injected at pipeline runtime via `--from-literal`. The following secrets are configured:

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Service principal JSON for AKS access |
| `DOCKER_PASSWORD` | Docker Hub Personal Access Token |
| `APP_SECRET` | JWT signing secret |
| `MONGODB_URI` | MongoDB connection string |
| `CLOUD_NAME` | Cloudinary cloud name |
| `CLOUD_API_KEY` | Cloudinary API key |
| `CLOUD_API_SECRET` | Cloudinary API secret |

---

## 2. Authentication & Authorization

### JWT Authentication
The `auth` microservice issues **JWT tokens** signed with `HS256` using a shared secret (`SECRET` env var). Tokens expire after 6 hours.

### Token Validation
The `discounts` and `items` microservices validate incoming JWTs via the `isAuthenticated` middleware before processing protected routes. Tokens are passed in the `Authorization: Bearer <token>` header.

### Password Security
User passwords are hashed using **bcryptjs** with 10 salt rounds before being stored in MongoDB. Plain text passwords are never stored or logged.

### Role-Based Access
The `auth` microservice supports user roles stored in the JWT payload. Role enforcement is handled at the route level in each microservice.

---

## 3. Network Security

### Kubernetes Ingress
Only the NGINX Ingress Controller is exposed publicly. All microservices and MongoDB use `ClusterIP` services — they are not reachable from outside the cluster.

Public entry points:
```
https://gerald.az.ironlabs.online       → Restauranty app (Ingress)
https://grafana.gerald.az.ironlabs.online → Grafana monitoring (Ingress)
```

### Grafana NetworkPolicy
Access to Grafana is restricted via a Kubernetes `NetworkPolicy`:
- Only traffic from the NGINX Ingress Controller namespace is allowed
- Only traffic from the ISP CIDR block `79.192.0.0/10` (Vodafone Germany) is allowed
- Anonymous access is disabled — admin credentials required

### MongoDB
MongoDB is deployed as a `ClusterIP` service — only accessible from within the `restauranty` namespace. It is not exposed externally.

---

## 4. TLS / HTTPS

All public endpoints are served over HTTPS:
- TLS certificates are issued automatically by **Let's Encrypt** via **cert-manager**
- The `ClusterIssuer` uses the HTTP-01 ACME challenge
- HTTP traffic is automatically redirected to HTTPS (`308 Permanent Redirect`)
- Certificates auto-renew before expiry (cert-manager handles this)

Check certificate status:
```bash
kubectl get certificate -n restauranty
kubectl get certificate -n monitoring
```

---

## 5. Container Security

### Base Images
All microservice images use `node:20-alpine` — minimal attack surface, no unnecessary packages.

The React frontend uses a two-stage build:
- Stage 1: `node:20-alpine` for building
- Stage 2: `nginx:stable-alpine` for serving — Node.js is not present in the final image

### Dependency Management
- `npm ci --omit=dev` is used in backend Dockerfiles — dev dependencies are excluded from production images
- `node_modules` is excluded from Docker build context via `.dockerignore`

### Image Tags
Each CI/CD pipeline run tags images with the Git commit SHA (`${{ github.sha }}`) in addition to `latest` — enabling rollback to any previous commit.

---

## 6. IAM & Azure Security

### AKS Managed Identity
The AKS cluster uses a **managed identity** (`--enable-managed-identity`) — no static credentials are stored for cluster operations.

### GitHub Actions Service Principal
A dedicated Azure service principal (`restauranty-github-actions-gerald`) with **Contributor** scope limited to the `geraldAKSGroup` resource group is used for CI/CD deployments. It has no access beyond that resource group.

Rotate credentials periodically:
```bash
az ad sp credential reset --id <appId>
```

---

## 7. Data & Compliance

### Data Storage
User data (name, email, address, phone number, hashed password) is stored in MongoDB running inside the AKS cluster on a PersistentVolumeClaim backed by Azure managed disks.

### Encryption at Rest
Azure managed disks are encrypted at rest by default using **Azure Storage Service Encryption (SSE)** with platform-managed keys.

### Encryption in Transit
All traffic between the browser and the cluster is encrypted via TLS. Internal cluster traffic between microservices travels over the Kubernetes pod network.

### GDPR Considerations
- Passwords are hashed and never stored in plain text
- No third-party analytics or tracking scripts are used in the frontend
- User data is stored in the EU region (`eastus` — note: for full GDPR compliance consider `westeurope` or `northeurope` regions)
- Cloudinary is used for image storage — review [Cloudinary's GDPR compliance](https://cloudinary.com/privacy) for data processing agreements

---

## 8. Reporting Security Issues

If you discover a security vulnerability in this project, please open a private issue on GitHub or contact the maintainer directly. Do not disclose security issues publicly until they have been addressed.
