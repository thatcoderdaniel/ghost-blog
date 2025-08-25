#!/bin/bash

echo "🔧 Testing Ghost with minimal configuration to isolate the issue..."

# Deploy with SQLite first to test if it's a database issue
echo "📦 Deploying Ghost with SQLite (no database connection issues)..."
gcloud run deploy ghost-blog-test \
  --image=ghost:5-alpine \
  --region=us-central1 \
  --allow-unauthenticated \
  --platform=managed \
  --port=2368 \
  --memory=1Gi \
  --cpu=1 \
  --max-instances=3 \
  --timeout=300 \
  --set-env-vars="NODE_ENV=development,url=https://ghost-blog-test-572266609014.us-central1.run.app"

echo "⏳ Waiting 30 seconds for deployment..."
sleep 30

echo "🧪 Testing SQLite version..."
curl -I https://ghost-blog-test-572266609014.us-central1.run.app

echo "📋 Getting logs..."
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=ghost-blog-test" --limit=5 --format="value(textPayload)"

echo "✅ SQLite test complete!"