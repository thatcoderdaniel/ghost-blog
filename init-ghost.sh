#!/bin/bash

echo "🚀 Starting Ghost initialization and deployment fix..."

# Create a better Ghost configuration
cat > /tmp/ghost-config.json << 'EOF'
{
  "url": "https://ghost-blog-572266609014.us-central1.run.app",
  "server": {
    "port": 2368,
    "host": "0.0.0.0"
  },
  "database": {
    "client": "mysql2",
    "connection": {
      "host": "104.154.201.91",
      "port": 3306,
      "user": "ghost",
      "password": "GhostSecure2024!",
      "database": "ghost_production",
      "charset": "utf8mb4"
    },
    "pool": {
      "min": 0,
      "max": 5
    },
    "debug": false
  },
  "logging": {
    "level": "info",
    "rotation": {
      "enabled": false
    },
    "transports": [
      "stdout"
    ]
  },
  "mail": {
    "transport": "Direct"
  },
  "process": "local",
  "paths": {
    "contentPath": "/var/lib/ghost/content"
  }
}
EOF

echo "✅ Ghost config created. Deploying with debug logging..."

# Deploy with simplified approach
gcloud run deploy ghost-blog \
  --image=ghost:5-alpine \
  --region=us-central1 \
  --allow-unauthenticated \
  --platform=managed \
  --port=2368 \
  --memory=2Gi \
  --cpu=2 \
  --max-instances=5 \
  --timeout=900 \
  --add-cloudsql-instances=dmisblogging-prod:us-central1:ghost-blog-db \
  --set-env-vars="NODE_ENV=production" \
  --set-env-vars="database__client=mysql2" \
  --set-env-vars="database__connection__host=104.154.201.91" \
  --set-env-vars="database__connection__port=3306" \
  --set-env-vars="database__connection__user=ghost" \
  --set-env-vars="database__connection__password=GhostSecure2024!" \
  --set-env-vars="database__connection__database=ghost_production" \
  --set-env-vars="url=https://ghost-blog-572266609014.us-central1.run.app"

echo "🎯 Deployment complete! Testing connectivity..."

sleep 30

# Test the deployment
curl -s -o /dev/null -w "Status: %{http_code}\nTime: %{time_total}s\n" https://ghost-blog-572266609014.us-central1.run.app || echo "Connection failed"

echo "🔍 Checking logs for any issues..."
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=ghost-blog" --limit=5 --format="value(textPayload)"

echo "✅ Setup complete!"