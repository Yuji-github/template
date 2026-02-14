# STAGE 1: Builder
FROM python:3.12-slim as builder

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# 1. Install ONLY build tools here
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN pip install poetry

WORKDIR /workspace

COPY pyproject.toml poetry.lock ./

RUN poetry install --without dev --no-root

# STAGE 2: Runtime (The final image)
FROM python:3.12-slim as runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/workspace/.venv/bin:$PATH"

WORKDIR /workspace

# 2. Install FONTS here
RUN apt-get update && apt-get install -y --no-install-recommends \
    fonts-ipafont-gothic \
    fonts-ipafont-mincho \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user
RUN addgroup --system appgroup && adduser --system --group appuser

# Copy virtualenv from builder
COPY --from=builder --chown=appuser:appgroup /workspace/.venv /workspace/.venv

# Copy source code
COPY --chown=appuser:appgroup src /workspace/src

USER appuser

EXPOSE 8050

CMD ["python", "src/main.py"]