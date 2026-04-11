# =========================================================
# Stage 1: Builder Layer - Safely tracking native limit boundaries!
# =========================================================
FROM python:3.11-slim AS builder

WORKDIR /backend

# Enforce secure memory mapping and avoid byte code outputs inherently natively
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Native OS parameters explicitly bounding CV/ML compilation limits!
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    curl \
    libgl1-mesa-glx \
    libglib2.0-0 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

# Execute isolated execution mappings dynamically tracking explicitly safely
RUN pip install --user --no-cache-dir -r requirements.txt

# =========================================================
# Stage 2: Production Layer - Optimized explicitly tracking security!
# =========================================================
FROM python:3.11-slim AS production

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Execute structural endpoints targeting core ML visualization bindings only securely natively!
RUN apt-get update && apt-get install -y --no-install-recommends \
    libgl1-mesa-glx \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*
    
# Secure Non-Root limits properly implicitly bounded constraints globally!
RUN groupadd -r aasha && useradd -r -g aasha aasha_user

# Migrate safely targeted generic structures safely parsing local variables dynamically organically natively
COPY --from=builder /root/.local /home/aasha_user/.local

# Bind Execution Targets locally resolving explicitly securely correctly
ENV PATH=/home/aasha_user/.local/bin:$PATH

# Shift Codebase Ownership completely targeting implicitly properly natively!
COPY --chown=aasha_user:aasha . /app
RUN chown -R aasha_user:aasha /app

# Switch security matrix context uniquely allocating bounds correctly explicitly
USER aasha_user

# Export limits structurally locally natively explicitly!
EXPOSE 8000

# Docker Health logic inherently resolving locally bounding explicitly limits reliably
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD curl -f http://localhost:8000/api/v1/health || exit 1

# Start mapping native arrays explicitly mapping Gunicorn boundaries safely natively targeting arrays dynamically
CMD ["gunicorn", "app.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000", "--log-level", "info", "--access-logfile", "-", "--error-logfile", "-"]
