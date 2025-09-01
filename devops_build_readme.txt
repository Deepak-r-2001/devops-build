# README.md
# DevOps Build Project: React Application Deployment

## Project Overview
This project demonstrates the deployment of a React application in a production-ready environment using Docker, Jenkins, and AWS. The CI/CD pipeline builds, pushes, and deploys the application automatically based on Git branch updates.

---

## Repository URL
[GitHub Repo](https://github.com/Deepak-r-2001/devops-build)

## Deployed Site URL
[Deployed Application](http://13.201.123.30/)

## Docker Hub Repositories
- **Dev Repo (Public):** `deepwhoo/devops-build:dev`
- **Prod Repo (Private):** `deepwhoo/devops-build:prod`

---

## Setup Instructions

### 1. Clone the Repository
```bash
git clone -b dev https://github.com/Deepak-r-2001/devops-build.git
cd devops-build
```

### 2. Dockerize Application
- Create `Dockerfile` to build the React app image.
- Create `docker-compose.yml` to run the application on port 80.

### 3. Bash Scripts
- `build.sh` - Builds Docker images.
- `deploy.sh` - Deploys images to the server.

### 4. Push Code to GitHub
```bash
git add .
git commit -m "Initial commit"
git push origin dev
```

### 5. Jenkins CI/CD Pipeline
- Jenkins monitors `dev` and `master` branches.
- On push to `dev`, Docker image builds and pushes to Dev repo.
- On merge to `master`, Docker image pushes to Prod repo.
- Jenkins is configured to deploy the application automatically.

### 6. AWS EC2 Setup
- Launch a `t2.micro` instance.
- Configure Security Groups:
  - Allow HTTP (port 80) from anywhere or your IP.
  - Allow SSH access from your IP only.
- Deploy the application using Docker and `deploy.sh`.

### 7. Monitoring
- Prometheus & Grafana are set up to monitor application health.
- Alerts configured to notify if the application goes down.

---

## Pipeline Explanation
1. **Development Workflow:**
   - Push code to `dev` branch → Jenkins builds image → Push to Dev Docker Hub repo → Deploy to dev server.
2. **Production Workflow:**
   - Merge `dev` into `master` → Jenkins builds image → Push to Prod Docker Hub repo → Deploy to production server.
3. **Monitoring:**
   - Prometheus collects metrics from the application.
   - Grafana dashboard displays application health and resource usage.
