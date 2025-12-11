# Simple production-ish Dockerfile for Flask app

FROM python:3.11-slim

WORKDIR /app

# Install system deps if needed (curl, etc.)
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY . .

# Flask app listens on 5000
EXPOSE 5000

# Simple healthcheck
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
