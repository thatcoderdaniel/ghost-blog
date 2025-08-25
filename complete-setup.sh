#!/bin/bash

echo "🔍 Waiting for Cloud SQL database to be ready..."

# Wait for database to be ready
while true; do
  STATUS=$(gcloud sql instances describe ghost-blog-db --format="value(state)" 2>/dev/null)
  echo "$(date): Database status - $STATUS"
  
  if [ "$STATUS" = "RUNNABLE" ]; then
    echo "✅ Database is ready! Continuing with setup..."
    break
  fi
  
  sleep 30
done

echo "🗄️ Setting up Ghost database and user..."

# Set root password
gcloud sql users set-password root --host=% --instance=ghost-blog-db --password="RootSecure2024!"

# Create Ghost database
gcloud sql databases create ghost_production --instance=ghost-blog-db

# Create Ghost user
gcloud sql users create ghost --host=% --instance=ghost-blog-db --password="GhostSecure2024!"

# Grant permissions
echo "📝 Database setup complete!"

# Get database connection details
DB_IP=$(gcloud sql instances describe ghost-blog-db --format="value(ipAddresses[0].ipAddress)")
echo "Database IP: $DB_IP"

echo "🚀 Updating Ghost deployment with database connection..."

# Update Cloud Run service with database connection
gcloud run deploy ghost-blog \
  --image=gcr.io/dmisblogging-prod/ghost-blog:latest \
  --region=us-central1 \
  --allow-unauthenticated \
  --platform=managed \
  --port=2368 \
  --memory=1Gi \
  --cpu=1 \
  --max-instances=10 \
  --add-cloudsql-instances=dmisblogging-prod:us-central1:ghost-blog-db \
  --set-env-vars="NODE_ENV=production,database__client=mysql2,database__connection__host=/cloudsql/dmisblogging-prod:us-central1:ghost-blog-db,database__connection__user=ghost,database__connection__password=GhostSecure2024!,database__connection__database=ghost_production,url=https://ghost-blog-572266609014.us-central1.run.app"

echo "✅ Ghost setup complete!"
echo "🌐 Ghost URL: https://ghost-blog-572266609014.us-central1.run.app"
echo "🔧 Admin URL: https://ghost-blog-572266609014.us-central1.run.app/ghost"

echo "🎉 Your Ghost blog is now ready! You can:"
echo "1. Visit the admin URL to set up your account"
echo "2. Start writing your first post"
echo "3. Configure your custom domain later"