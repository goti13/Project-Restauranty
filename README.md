# 🍽️ Restauranty — End-to-End DevOps Deployment

> A production-grade, cloud-native deployment of a full-stack restaurant management platform — containerized with Docker, orchestrated on Kubernetes (AKS), secured with TLS, monitored with Prometheus & Grafana, and fully automated via CI/CD.

[![CI/CD](https://github.com/goti13/Project-Restauranty/actions/workflows/ci-cd.yaml/badge.svg)](https://github.com/goti13/Project-Restauranty/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5?logo=kubernetes&logoColor=white)](https://azure.microsoft.com/en-us/products/kubernetes-service)
[![Docker](https://img.shields.io/badge/Docker-Hub-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/u/otigerald)
[![Grafana](https://img.shields.io/badge/Grafana-Monitoring-F46800?logo=grafana&logoColor=white)](https://grafana.gerald.az.ironlabs.online)

---

## 🌐 Live Application

| Endpoint | URL |
|---|---|
| **Application** | https://gerald.az.ironlabs.online |
| **Grafana Dashboard** | https://grafana.gerald.az.ironlabs.online |

---

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Microservices](#-microservices)
- [Repository Structure](#-repository-structure)
- [Local Development](#-local-development)
- [Containerization](#-containerization)
- [Kubernetes Deployment](#-kubernetes-deployment)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Monitoring & Logging](#-monitoring--logging)
- [Security](#-security)
- [Environment Variables](#-environment-variables)
- [Author](#-author)

---

## 🎯 Project Overview

Restauranty is a microservices-based restaurant management platform. This repository documents its complete **DevOps implementation** — from local development to a fully automated, production-ready cloud deployment on **Azure Kubernetes Service (AKS)**.

### What was implemented

| Area | Implementation |
|---|---|
| **Containerization** | Docker multi-stage builds for all 4 services |
| **Orchestration** | Kubernetes on AKS with Deployments, Services, Ingress |
| **TLS/HTTPS** | cert-manager + Let's Encrypt auto-issued certificates |
| **CI/CD** | GitHub Actions — build, test, push, deploy on every commit |
| **Monitoring** | Prometheus + Grafana via Helm (kube-prometheus-stack) |
| **Logging** | Loki + Promtail — centralized log aggregation in Grafana |
| **Security** | NetworkPolicies, K8s Secrets, JWT auth, bcrypt, RBAC |
| **DNS** | Azure DNS — automated A record management via CLI |

---

## 🏗️ Architecture

```
  ┌─────────────┐         ┌──────────────────────────────────────────────────────┐
  │   Browser   │─HTTPS──►│              Azure Kubernetes Service                │
  └─────────────┘         │                                                      │
                          │   ┌──────────────────────────────────────────────┐   │
  ┌─────────────┐         │   │           NGINX Ingress Controller           │   │
  │GitHub Action│         │   └───────┬──────────┬──────────┬────────────────┘   │
  │  CI/CD pipe │         │           │          │          │                    │
  └──────┬──────┘         │           ▼          ▼          ▼                    │
         │                │   ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌────────┐  │
         ▼                │   │   Auth   │ │  Items   │ │Discounts │ │  React │  │
  ┌─────────────┐         │   │  :3001   │ │  :3003   │ │  :3002   │ │  :80   │  │
  │ Docker Hub  │────────►│   └────┬─────┘ └────┬─────┘ └────┬─────┘ └────────┘  │
  │  (registry) │         │        └────────────┼────────────┘                   │
  └─────────────┘         │                     ▼                                │
                          │              ┌─────────────┐                         │
                          │              │   MongoDB   │                         │
                          │              │ ClusterIP   │                         │
                          │              └─────────────┘                         │
                          │                                                      │
                          │   ┌──────────────────────────────────────────────┐   │
                          │   │             monitoring namespace             │   │
                          │   │     Prometheus · Grafana · Loki · Promtail   │   │
                          │   └──────────────────────────────────────────────┘   │
                          └──────────────────────────┬───────────────────────────┘
                                                     │
                                        ┌────────────▼──────────────┐
                                        │        Azure DNS          │
                                        │  gerald.az.ironlabs.online│
                                        │  grafana.gerald.az...     │
                                        └───────────────────────────┘
```

---

## 🛠️ Tech Stack

### Application
![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=node.js&logoColor=white)
![React](https://img.shields.io/badge/React-18-61DAFB?logo=react&logoColor=black)
![MongoDB](https://img.shields.io/badge/MongoDB-7-47A248?logo=mongodb&logoColor=white)
![Express](https://img.shields.io/badge/Express.js-4-000000?logo=express&logoColor=white)

### DevOps & Infrastructure
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-AKS-0078D4?logo=microsoftazure&logoColor=white)
![Helm](https://img.shields.io/badge/Helm-3-0F1689?logo=helm&logoColor=white)
![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-CI/CD-2088FF?logo=githubactions&logoColor=white)

### Monitoring & Security
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)
![Loki](https://img.shields.io/badge/Loki-Logging-F46800?logo=grafana&logoColor=white)
![cert-manager](https://img.shields.io/badge/cert--manager-Let's_Encrypt-003A70)

---

## 🔧 Microservices

| Service | Port | Path | Responsibilities |
|---|---|---|---|
| **Auth** | 3001 | `/api/auth/*` | User signup, login, JWT authentication |
| **Discounts** | 3002 | `/api/discounts/*` | Coupon and campaign management |
| **Items** | 3003 | `/api/items/*` | Menu items, dietary categories, orders |
| **Frontend** | 3000 | `/` | React SPA — admin dashboard |

All services expose a `/metrics` endpoint compatible with **Prometheus** scraping.

---

## 📁 Repository Structure

```
project-restauranty/
├── backend/
│   ├── auth/                   # Auth microservice
│   │   ├── Dockerfile
│   │   └── ...
│   ├── discounts/              # Discounts microservice
│   │   ├── Dockerfile
│   │   └── ...
│   └── items/                  # Items microservice
│       ├── Dockerfile
│       └── ...
├── client/                     # React frontend
│   ├── Dockerfile
│   ├── nginx.conf
│   └── ...
├── k8s/                        # Kubernetes manifests
│   ├── namespace.yaml
│   ├── mongo.yaml
│   ├── auth.yaml
│   ├── discounts.yaml
│   ├── items.yaml
│   ├── frontend.yaml
│   ├── ingress.yaml
│   ├── cluster-issuer.yaml
│   └── monitoring/             # Helm values for monitoring
│       ├── prometheus-values.yaml
│       ├── loki-values.yaml
│       └── network-policy.yaml
├── .github/
│   └── workflows/
│       └── ci-cd.yaml          # GitHub Actions CI/CD pipeline
├── haproxy.cfg                 # Local HAProxy config
├── build-and-push.sh           # Build & push Docker images
├── aks-create.sh               # Create AKS cluster
├── aks-dns.sh                  # Update Azure DNS
├── aks-teardown.sh             # Delete AKS cluster
├── k8s-deploy.sh               # Deploy to Kubernetes
├── k8s-teardown.sh             # Teardown Kubernetes resources
├── monitoring-deploy.sh        # Deploy monitoring stack
├── secrets.env.example         # Secret template (commit this)
├── secrets.env                 # Real secrets (git-ignored)
├── SECURITY.md                 # Security & compliance documentation
└── README.md
```

---

## 💻 Local Development

### Prerequisites

- Node.js 20+
- Docker
- MongoDB (or use Docker)
- HAProxy

### Quick Start

**1. Clone the repository**
```bash
git clone https://github.com/goti13/Project-Restauranty.git
cd Project-Restauranty
```

**2. Start MongoDB**
```bash
docker run -d \
  --name my-mongo \
  -p 27017:27017 \
  -v mongo-data:/data/db \
  mongo:latest
```

**3. Configure environment variables**
```bash
# Each service has its own .env — copy from .env.example
cp backend/auth/.env.example backend/auth/.env
cp backend/discounts/.env.example backend/discounts/.env
cp backend/items/.env.example backend/items/.env
cp client/.env.example client/.env
# Fill in real values in each .env file
```

**4. Start all services**
```bash
# Terminal 1 — Auth
cd backend/auth && npm install && npm start

# Terminal 2 — Discounts
cd backend/discounts && npm install && npm start

# Terminal 3 — Items
cd backend/items && npm install && npm start

# Terminal 4 — Frontend
cd client && npm install && npm start
```

**5. Start HAProxy**
```bash
haproxy -f haproxy.cfg
```

Access the app at **http://localhost**

---

## 🐳 Containerization

All services are containerized using optimized Dockerfiles:

- **Backend services** — `node:20-alpine`, production dependencies only (`npm ci --omit=dev`)
- **Frontend** — Multi-stage build: Node builds the React app, nginx serves static files

### Build & Push Images

```bash
chmod +x build-and-push.sh

# Build and push with latest tag
./build-and-push.sh

# Build and push with version tag + production API URL
./build-and-push.sh v1.0.0 https://gerald.az.ironlabs.online
```

**Docker Hub images:**
```
otigerald/restauranty-auth:latest
otigerald/restauranty-discounts:latest
otigerald/restauranty-items:latest
otigerald/restauranty-client:latest
```

---

## ☸️ Kubernetes Deployment

### Prerequisites

- Azure CLI (`az`)
- kubectl
- Helm 3
- cert-manager (installed automatically by `aks-create.sh`)

### Create the AKS Cluster

```bash
chmod +x aks-create.sh
./aks-create.sh
```

This script automatically:
- Creates the Azure resource group
- Provisions a 3-node AKS cluster (Standard_B2s)
- Installs NGINX Ingress Controller
- Installs cert-manager + Let's Encrypt ClusterIssuer
- Configures `kubectl` context

### Deploy the Application

```bash
# 1. Build & push images
./build-and-push.sh v1.0.0 https://gerald.az.ironlabs.online

# 2. Configure secrets
cp secrets.env.example secrets.env
# Edit secrets.env with real values

# 3. Deploy to cluster
chmod +x k8s-deploy.sh
./k8s-deploy.sh

# 4. Point DNS at Ingress
chmod +x aks-dns.sh
./aks-dns.sh
```

### Teardown

```bash
# Remove app resources (keeps cluster)
./k8s-teardown.sh

# Delete entire AKS cluster
./aks-teardown.sh
```

---

## 🔄 CI/CD Pipeline

The GitHub Actions pipeline triggers on every push to `main` and runs three sequential jobs:

```
Push to main
     │
     ▼
┌─────────────────┐
│  Build & Test   │  Install deps, build each service, run tests
└────────┬────────┘
         │ on success
         ▼
┌─────────────────┐
│ Build & Push    │  Build Docker images, push to Docker Hub
│ Docker Images   │  Tagged with :latest and :${{ github.sha }}
└────────┬────────┘
         │ on success
         ▼
┌─────────────────┐
│  Deploy to AKS  │  Apply K8s manifests, rolling restart,
│                 │  wait for all rollouts to complete
└─────────────────┘
```

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `AZURE_CREDENTIALS` | Service principal JSON |
| `DOCKER_PASSWORD` | Docker Hub PAT |
| `APP_SECRET` | JWT signing secret |
| `MONGODB_URI` | MongoDB connection string |
| `CLOUD_NAME` | Cloudinary cloud name |
| `CLOUD_API_KEY` | Cloudinary API key |
| `CLOUD_API_SECRET` | Cloudinary API secret |

---

## 📊 Monitoring & Logging

The monitoring stack is deployed via **Helm** into the `monitoring` namespace.

### Deploy Monitoring

```bash
chmod +x monitoring-deploy.sh
./monitoring-deploy.sh
```

This installs:
- **kube-prometheus-stack** — Prometheus, Grafana, Alertmanager, Node Exporter, kube-state-metrics
- **loki-stack** — Loki (log storage) + Promtail (log collector DaemonSet)

### Access Grafana

| | |
|---|---|
| **URL** | https://grafana.gerald.az.ironlabs.online |
| **Username** | `admin` |
| **Password** | Set in `k8s/monitoring/prometheus-values.yaml` |

### Useful Loki Queries

```logql
# All restauranty logs
{namespace="restauranty"}

# Auth service logs only
{namespace="restauranty", app="auth"}

# Errors across all services
{namespace="restauranty"} |= "error"

# HTTP requests with status codes
{namespace="restauranty"} |~ "GET|POST|PUT|DELETE"
```

### Port-forward Prometheus locally

```bash
kubectl port-forward svc/prometheus-stack-kube-prom-prometheus \
  9090:9090 -n monitoring
```
Open: http://localhost:9090

### View Logs via kubectl

```bash
# Live logs
kubectl logs -l app=auth -n restauranty -f

# Last 100 lines
kubectl logs -l app=items -n restauranty --tail=100

# All services
kubectl logs -l app=discounts -n restauranty --all-containers=true
```

---

## 🔒 Security

See [SECURITY.md](SECURITY.md) for full details. Key highlights:

- **Secrets** — Never committed to Git; injected via `kubectl create secret --from-env-file` and GitHub Actions Secrets
- **TLS** — All traffic encrypted via Let's Encrypt certificates, auto-renewed by cert-manager
- **Network** — Only Ingress is public; all services use `ClusterIP`; Grafana protected by `NetworkPolicy`
- **Auth** — JWT tokens (HS256, 6h expiry); passwords hashed with bcrypt (10 rounds)
- **Images** — Alpine-based minimal images; no dev dependencies in production
- **IAM** — AKS managed identity; scoped service principal for CI/CD

---

## ⚙️ Environment Variables

### Backend Services (auth / discounts / items)

| Variable | Description |
|---|---|
| `SECRET` | JWT signing secret |
| `MONGODB_URI` | MongoDB connection string |
| `CLOUD_NAME` | Cloudinary cloud name |
| `CLOUD_API_KEY` | Cloudinary API key |
| `CLOUD_API_SECRET` | Cloudinary API secret |
| `PORT` | Service port (3001 / 3002 / 3003) |

### Frontend (client)

| Variable | Description |
|---|---|
| `REACT_APP_SERVER_URL` | Base API URL (injected at build time) |

---

## 👤 Author

**Gerald Oti**
DevOps Engineer | SRE | Platform Engineer

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Gerald_Oti-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/gerald-oti/)
[![GitHub](https://img.shields.io/badge/GitHub-goti13-181717?logo=github&logoColor=white)](https://github.com/goti13)

---

*Built as part of the IronHack DevOps Bootcamp — demonstrating end-to-end cloud infrastructure engineering on Azure.*# Project-Restauranty
