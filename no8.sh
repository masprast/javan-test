#!/bin/bash

# Jenkins CI/CD Script

PROJECT_NAME="your-project-name"
GIT_REPO="your-git-repository-url"
DEPLOYMENT_SERVER="username@server"
DEPLOYMENT_DIR="/path/to/deployment/directory"

echo "Cloning the repository..."
git clone $GIT_REPO $PROJECT_NAME
cd $PROJECT_NAME

echo "Install dependencies..."
npm install

echo "Menjalankan Tes..."
npm test

echo "Build project..."
npm run build

echo "Deploying..."
scp -r ./dist/* $DEPLOYMENT_SERVER:$DEPLOYMENT_DIR

echo "Deployment completed"
