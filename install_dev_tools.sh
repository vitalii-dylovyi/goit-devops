#!/bin/bash

# Install Docker (official docker-ce), Docker Compose plugin, Python 3.9+ and Django
# Works on Ubuntu/Debian
set -e

# --- Single, centralized package-index update ---
echo "Updating apt package index..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg software-properties-common lsb-release

# --- Docker (official docker-ce packages) ---
if command -v docker &> /dev/null; then
    echo "Docker is already installed: $(docker --version)"
else
    echo "Installing Docker (docker-ce)..."
    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
        sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
        docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker "$USER"
    echo "Docker installed"
fi

# --- Docker Compose (plugin ships with docker-ce; verify) ---
if docker compose version &> /dev/null; then
    echo "Docker Compose is available: $(docker compose version)"
else
    echo "Installing Docker Compose plugin..."
    sudo apt-get install -y docker-compose-plugin
    echo "Docker Compose installed"
fi

# --- Python 3.9+ (explicit version via deadsnakes PPA) ---
if command -v python3.9 &> /dev/null; then
    echo "Python 3.9 is already installed: $(python3.9 --version)"
else
    echo "Installing Python 3.9..."
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt-get update
    sudo apt-get install -y python3.9 python3.9-venv python3.9-distutils
    curl -fsSL https://bootstrap.pypa.io/get-pip.py | sudo python3.9
    echo "Python installed: $(python3.9 --version)"
fi

# --- Django (for Python 3.9) ---
if python3.9 -m django --version &> /dev/null; then
    echo "Django is already installed: $(python3.9 -m django --version)"
else
    echo "Installing Django..."
    python3.9 -m pip install --user django
    echo "Django installed: $(python3.9 -m django --version)"
fi

echo "All tools are installed!"
