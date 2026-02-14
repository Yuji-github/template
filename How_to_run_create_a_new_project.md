# How to run create_new_project.sh
`cd /home/usr/Path/create_new_project.sh ANY_PROJECT_NAME`

# Project Name

## 🚀 Getting Started

This project was generated using the **Factory Template**.
It comes pre-configured with Docker, Poetry, Pytest, and VS Code Debugging.

### 1. Prerequisites
* Docker Desktop / Docker Engine
* VS Code
* "Dev Containers" extension for VS Code

### 2. How to Run
1.  Open this folder in VS Code.
2.  Press `F1` and select **"Dev Containers: Reopen in Container"**.
3.  Wait for the build to finish.

### 3. Dependency Management
This project uses **Poetry**.
* **Add a library:** `poetry add pandas`
* **Add a dev tool:** `poetry add --group dev black`

### 4. Running Tests
* **Via UI:** Go to the Testing tab (Beaker icon) in VS Code.
* **Via Terminal:** Run `pytest` inside the integrated terminal.

### 5. Debugging
Press `F5` to start debugging.
* **"Python: Current File"**: Debugs the open file.
* **"Python: Debug Tests"**: Debugs your unit tests.

