#!/usr/bin/env bash
set -euo pipefail

# Update these variables
SERVER="${SERVER:-ubuntu@13.201.123.30}"  # Your EC2 IP
SSH_KEY="${SSH_KEY:-/c/Users/dr222/Downloads/ssh.pem.3.pem}"  # Path to your PEM file
REMOTE_DIR="${REMOTE_DIR:-/opt/react-app}"
APP_IMAGE="${APP_IMAGE:-docker.io/deepwhoo/prod:latest}"  # Your DockerHub image
DOCKERHUB_USER="${DOCKERHUB_USER:-deepwhoo}"
DOCKERHUB_PASS="${DOCKERHUB_PASS:-Deepak@8217}"  # Optional if public repo

SSH_OPTS="-o StrictHostKeyChecking=no"
if [[ -n "$SSH_KEY" ]]; then
  SSH_OPTS="$SSH_OPTS -i $SSH_KEY"
fi

echo ">> Preparing remote directory on $SERVER"
ssh $SSH_OPTS "$SERVER" "sudo mkdir -p $REMOTE_DIR && sudo chown \$USER:\$USER $REMOTE_DIR"

echo ">> Uploading docker-compose.yml"
scp $SSH_OPTS docker-compose.yml "$SERVER":"$REMOTE_DIR"/

# Create .env file remotely
ssh $SSH_OPTS "$SERVER" bash -lc "cat > $REMOTE_DIR/.env <<EOF
APP_IMAGE=${APP_IMAGE}
EOF"

echo ">> Logging into Docker Hub, pulling and starting"
ssh $SSH_OPTS "$SERVER" bash -lc "
  if ! command -v docker &>/dev/null; then
    echo 'Docker not installed. Installing Docker...'
    sudo apt update -y && sudo apt install -y docker.io docker-compose
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker \$USER
  fi

  if command -v docker compose &>/dev/null; then
    DC='docker compose'
  else
    DC='docker-compose'
  fi

  if [[ -n '${DOCKERHUB_PASS}' ]]; then
    echo '${DOCKERHUB_PASS}' | docker login -u '${DOCKERHUB_USER}' --password-stdin
  fi

  cd $REMOTE_DIR
  \$DC pull
  \$DC up -d
  docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'
"

echo ">> Deploy complete."
