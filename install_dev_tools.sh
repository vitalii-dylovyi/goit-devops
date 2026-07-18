#!/bin/bash

# Script to install Docker, Docker Compose, Python and Django
# Works on Ubuntu/Debian

set -e

# Docker
if command -v docker &> /dev/null; then
    echo "Docker is already installed"
else
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
    echo "Docker installed"
fi

# Docker Compose
if docker compose version &> /dev/null; then
    echo "Docker Compose is already installed"
else
    echo "Installing Docker Compose..."
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    echo "Docker Compose installed"
fi

# Python
if command -v python3 &> /dev/null; then
    echo "Python is already installed: $(python3 --version)"
else
    echo "Installing Python..."
    sudo apt-get update
    sudo apt-get install -y python3 python3-pip
    echo "Python installed"
fi

# Django
if python3 -m django --version &> /dev/null; then
    echo "Django is already installed: $(python3 -m django --version)"
else
    echo "Installing Django..."
    pip3 install django
    echo "Django installed"
fi

echo "All tools are installed!"
