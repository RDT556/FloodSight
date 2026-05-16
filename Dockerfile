# ─────────────────────────────────────────────────────────────────────────────
# Flood DAS — Production Dockerfile
# Base: slim Python 3.11 with GDAL/rasterio wheels available via pip
# ─────────────────────────────────────────────────────────────────────────────

FROM python:3.11-slim

# System dependencies required by rasterio, shapely, and psycopg2-binary
RUN apt-get update && apt-get install -y --no-install-recommends \
        gdal-bin \
        libgdal-dev \
        libgeos-dev \
        gcc \
        g++ \
    && rm -rf /var/lib/apt/lists/*

# ── Working directory ─────────────────────────────────────────────────────────
WORKDIR /app

# ── Python dependencies ───────────────────────────────────────────────────────
# Copy requirements first so Docker can cache this layer independently
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt

# ── Application source ────────────────────────────────────────────────────────
COPY . .

# ── Runtime configuration ─────────────────────────────────────────────────────
# Expose the port uvicorn will listen on
EXPOSE 8000

# Use environment variables for configuration (see .env.example)
ENV DATABASE_URL="sqlite:///./flood_das.db" \
    ECHO_SQL="false" \
    CORS_ORIGINS="*" \
    PORT=8000

# ── Start server ──────────────────────────────────────────────────────────────
CMD ["sh", "-c", "uvicorn backend.main:app --host 0.0.0.0 --port ${PORT}"]
