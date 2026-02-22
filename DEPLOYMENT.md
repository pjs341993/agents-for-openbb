# Docker Deployment Example

This directory contains example Docker configurations for deploying OpenBB agents.

## Single Agent Deployment

### Using Docker

1. Create a `Dockerfile` in your agent directory (e.g., `30-vanilla-agent-raw-widget-data/Dockerfile`):

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# Install poetry
RUN pip install poetry

# Copy project files
COPY pyproject.toml poetry.lock ./
COPY 30-vanilla-agent-raw-widget-data ./30-vanilla-agent-raw-widget-data

# Install dependencies
RUN poetry config virtualenvs.create false && \
    poetry install --no-root --no-dev

# Expose port
EXPOSE 7777

# Set environment variables (override these when running)
ENV OPENAI_API_KEY=""

# Run the application
CMD ["poetry", "run", "uvicorn", "vanilla_agent_raw_context.main:app", "--host", "0.0.0.0", "--port", "7777"]
```

2. Build the image:
```bash
cd /path/to/agents-for-openbb
docker build -t openbb-agent:vanilla-raw-context -f 30-vanilla-agent-raw-widget-data/Dockerfile .
```

3. Run the container:
```bash
docker run -d \
  -p 7777:7777 \
  -e OPENAI_API_KEY=your-key-here \
  --name openbb-agent \
  openbb-agent:vanilla-raw-context
```

4. Check logs:
```bash
docker logs -f openbb-agent
```

5. Stop the container:
```bash
docker stop openbb-agent
docker rm openbb-agent
```

## Multi-Agent Deployment with Docker Compose

Create a `docker-compose.yml` in the repository root:

```yaml
version: '3.8'

services:
  agent-raw-context:
    build:
      context: .
      dockerfile: 30-vanilla-agent-raw-widget-data/Dockerfile
    ports:
      - "7777:7777"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    restart: unless-stopped

  agent-charts:
    build:
      context: .
      dockerfile: 33-vanilla-agent-charts/Dockerfile
    ports:
      - "7778:7777"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    restart: unless-stopped

  agent-tables:
    build:
      context: .
      dockerfile: 34-vanilla-agent-tables/Dockerfile
    ports:
      - "7779:7777"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
    restart: unless-stopped
```

Create a `.env` file:
```
OPENAI_API_KEY=your-key-here
```

Start all agents:
```bash
docker-compose up -d
```

View logs:
```bash
docker-compose logs -f
```

Stop all agents:
```bash
docker-compose down
```

## Production Deployment

For production, consider:

1. **Use a reverse proxy** (nginx, Traefik, Caddy) for HTTPS
2. **Set resource limits**:
   ```yaml
   services:
     agent-raw-context:
       # ...
       deploy:
         resources:
           limits:
             cpus: '0.5'
             memory: 512M
           reservations:
             cpus: '0.25'
             memory: 256M
   ```

3. **Add health checks**:
   ```yaml
   services:
     agent-raw-context:
       # ...
       healthcheck:
         test: ["CMD", "curl", "-f", "http://localhost:7777/agents.json"]
         interval: 30s
         timeout: 10s
         retries: 3
         start_period: 40s
   ```

4. **Use secrets for API keys** (Docker Swarm or Kubernetes)

## Cloud Deployment Options

### AWS ECS / Fargate
- Use the Dockerfile above
- Push to ECR (Elastic Container Registry)
- Create ECS task definition with environment variables
- Deploy to Fargate for serverless containers

### Google Cloud Run
```bash
# Build and deploy
gcloud builds submit --tag gcr.io/PROJECT_ID/openbb-agent
gcloud run deploy openbb-agent \
  --image gcr.io/PROJECT_ID/openbb-agent \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars OPENAI_API_KEY=your-key
```

### Azure Container Instances
```bash
az container create \
  --resource-group myResourceGroup \
  --name openbb-agent \
  --image myregistry.azurecr.io/openbb-agent \
  --dns-name-label openbb-agent \
  --ports 7777 \
  --environment-variables OPENAI_API_KEY=your-key
```

### Kubernetes
Create a deployment:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: openbb-agent
spec:
  replicas: 2
  selector:
    matchLabels:
      app: openbb-agent
  template:
    metadata:
      labels:
        app: openbb-agent
    spec:
      containers:
      - name: openbb-agent
        image: your-registry/openbb-agent:latest
        ports:
        - containerPort: 7777
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: openbb-secrets
              key: openai-api-key
---
apiVersion: v1
kind: Service
metadata:
  name: openbb-agent
spec:
  selector:
    app: openbb-agent
  ports:
  - port: 80
    targetPort: 7777
  type: LoadBalancer
```

## Security Best Practices

1. **Never commit secrets** - Use environment variables or secret managers
2. **Use HTTPS in production** - Encrypt traffic with TLS/SSL
3. **Implement rate limiting** - Prevent abuse
4. **Monitor and log** - Track usage and errors
5. **Keep dependencies updated** - Regularly update packages
6. **Use minimal base images** - Reduce attack surface
7. **Run as non-root user** in Docker:
   ```dockerfile
   RUN useradd -m -u 1000 appuser
   USER appuser
   ```

## Monitoring

Add monitoring with Prometheus and Grafana:

```yaml
# docker-compose.yml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
```

For more deployment options, see the main [Integration Guide](../INTEGRATION_GUIDE.md).
