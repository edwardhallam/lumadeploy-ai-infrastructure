FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy application files
COPY scripts/webhook-server.py ./
COPY scripts/auto-prioritize-failures.sh ./
COPY scripts/realtime-monitor.sh ./

# Install Python dependencies
RUN pip install --no-cache-dir requests

# Create non-root user for security
RUN useradd -m -u 1000 webhook && chown -R webhook:webhook /app
USER webhook

# Expose webhook port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

# Set environment variables
ENV WEBHOOK_PORT=8080
ENV WEBHOOK_LOG_FILE=/tmp/github_webhook.log
ENV PYTHONUNBUFFERED=1

# Run the webhook server
CMD ["python", "webhook-server.py"]
