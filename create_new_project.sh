#!/bin/bash

# --- CONFIGURATION ---
SOURCE_DIR="/home/usr/PycharmProjects/template"
NEW_PROJECT_NAME=$1

# --- CHECKS ---
if [ -z "$NEW_PROJECT_NAME" ]; then
  echo "❌ Error: Please provide a project name."
  echo "Usage: ./create_new_project.sh my_new_app"
  exit 1
fi

if [ -d "$NEW_PROJECT_NAME" ]; then
  echo "❌ Error: A folder named '$NEW_PROJECT_NAME' already exists."
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo "❌ Error: Template folder not found at $SOURCE_DIR"
  exit 1
fi

echo "🏭 Factory Mode: creating '$NEW_PROJECT_NAME' from template..."
mkdir "$NEW_PROJECT_NAME"

# --- COPYING FILES ---
echo "📂 Copying infrastructure..."

# 1. DevContainer
cp -r "$SOURCE_DIR/.devcontainer" "$NEW_PROJECT_NAME/"

# 2. VS Code Configuration
if [ -d "$SOURCE_DIR/.vscode" ]; then
    echo "   ...copying .vscode settings"
    cp -r "$SOURCE_DIR/.vscode" "$NEW_PROJECT_NAME/"
fi

# 3. Docker Configs
cp "$SOURCE_DIR/Dockerfile" "$NEW_PROJECT_NAME/" 2>/dev/null || true
cp "$SOURCE_DIR/docker-compose.yml" "$NEW_PROJECT_NAME/" 2>/dev/null || true
cp "$SOURCE_DIR/.dockerignore" "$NEW_PROJECT_NAME/" 2>/dev/null || true
cp "$SOURCE_DIR/.gitignore" "$NEW_PROJECT_NAME/" 2>/dev/null || true

# 4. Terraform (Copy folder but EXCLUDE hidden .terraform folder)
if [ -d "$SOURCE_DIR/terraform" ]; then
    echo "   ...copying terraform"
    mkdir "$NEW_PROJECT_NAME/terraform"
    cp "$SOURCE_DIR/terraform/"*.tf "$NEW_PROJECT_NAME/terraform/" 2>/dev/null || true
    cp "$SOURCE_DIR/terraform/"*.tfvars "$NEW_PROJECT_NAME/terraform/" 2>/dev/null || true
fi

# 5. Test Folder
if [ -d "$SOURCE_DIR/test" ]; then
    echo "   ...copying test folder"
    cp -r "$SOURCE_DIR/test" "$NEW_PROJECT_NAME/"
fi

# --- INITIALIZING POETRY ---
echo "📦 Initializing clean Poetry environment..."
cd "$NEW_PROJECT_NAME"

poetry init --name "$NEW_PROJECT_NAME" \
    --description "Created via factory script" \
    --author "usr" \
    --python "^3.11" \
    --no-interaction

echo "🧪 Installing pytest..."
poetry add --group dev pytest

# Create lock file
poetry lock

# --- FINAL TOUCHES ---
mkdir src

# Update project name in devcontainer.json
if [ -f .devcontainer/devcontainer.json ]; then
    sed -i 's/"name": ".*"/"name": "'"$NEW_PROJECT_NAME"'"/' .devcontainer/devcontainer.json
fi

echo "✅ Factory Build Complete!"
echo "👉 Location: /home/usr/PycharmProjects/$NEW_PROJECT_NAME"
