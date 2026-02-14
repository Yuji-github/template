#!/bin/bash

# Use standard HOME variable (cleaner than eval)
USER_HOME="$HOME"

echo "🐍 Checking Python environment..."

# 1. Check if .venv exists but is broken
# (If created on Windows, the python binary won't run on Linux)
if [ -d ".venv" ]; then
    if ! ./.venv/bin/python --version > /dev/null 2>&1; then
        echo "⚠️  Detected broken .venv (likely from Host OS). Removing..."
        rm -rf .venv
    else
        echo "✅ Valid Linux .venv found."
    fi
fi

# 2. Configure Poetry
poetry config virtualenvs.in-project true

# 3. Install dependencies
echo "📦 Installing/Updating dependencies..."

# SCENARIO A: Brand New Project (Empty Folder)
if [ ! -f "pyproject.toml" ]; then
    echo "📄 No pyproject.toml found. Initializing new project..."
    
    # Initialize Poetry quietly
    poetry init --name "my-project" --python "^3.12" --dependency="" -n
    
    # Add pre-commit to dev dependencies
    poetry add --group dev pre-commit
    
    # Create the SPECIFIC config for Black + Jupyter (Better than sample-config)
    if [ ! -f ".pre-commit-config.yaml" ]; then
        echo "📝 Creating .pre-commit-config.yaml for Black & Jupyter..."
        cat > .pre-commit-config.yaml <<EOF
repos:
  - repo: https://github.com/psf/black
    rev: 24.10.0
    hooks:
      - id: black-jupyter
EOF
    fi

# SCENARIO B: Existing Project
else
    echo "✅ Found pyproject.toml. Installing..."
    poetry install --no-root
    
    # Check if pre-commit is missing from the environment (e.g. old project)
    # If 'poetry run pre-commit' fails, we add it.
    if ! poetry run pre-commit --version > /dev/null 2>&1; then
        echo "⚠️  pre-commit not found in environment. Adding it..."
        poetry add --group dev pre-commit
    fi
fi

echo "🪝 Installing Git hooks..."
# We must use 'poetry run' because pre-commit is inside the venv
if [ -d ".git" ]; then
    poetry run pre-commit install
else
    echo "⚠️  No .git folder found. Skipping hook install (Run 'git init' then restart container)."
fi

# 4. Git Configuration Checks
echo "🔧 Configuring Git..."

# 1. Link the Host Configuration (Read-Only Layer)
if [ -f "$USER_HOME/.gitconfig_host" ]; then
    echo "🔗 Linking host git configuration..."
    # This tells Git: "Use settings from the host, but let me override them here"
    git config --global include.path "$USER_HOME/.gitconfig_host"
else
    echo "⚠️  Host gitconfig not found. Using defaults."
    git config --global user.name "DevContainer User"
    git config --global user.email "dev@container.local"
fi

# 2. Apply Container-Specific Settings (Writable Layer)
echo "🔐 Setting safe directory..."
# This writes to /home/vscode/.gitconfig (Internal container file)
# It DOES NOT touch laptop's file.
git config --global --add safe.directory /workspace

echo "✅ Git configuration complete."
