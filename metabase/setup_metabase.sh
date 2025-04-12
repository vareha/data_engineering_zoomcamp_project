#!/bin/bash

# Setup script for Metabase installation and configuration

echo "===== AIS Data Project - Metabase Setup ====="
echo ""

# Create necessary directories
echo "Creating Metabase data directory..."
mkdir -p data
echo "Directory created: $(pwd)/data"
echo ""

# Check if docker-compose.yml exists
if [ -f "docker-compose.yml" ]; then
    echo "docker-compose.yml already exists."
else
    echo "Creating docker-compose.yml..."
    cat > docker-compose.yml << 'EOF'
version: '3'
services:
  metabase:
    image: metabase/metabase:latest
    container_name: metabase
    ports:
      - "3000:3000"
    volumes:
      - ./data:/metabase-data
    environment:
      - MB_DB_FILE=/metabase-data/metabase.db
      - JAVA_TIMEZONE=Europe/Lisbon
    restart: unless-stopped
EOF
    echo "docker-compose.yml created."
fi
echo ""

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker before continuing."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose before continuing."
    exit 1
fi

# BigQuery Service Account Instructions
echo "===== BigQuery Service Account Setup ====="
echo ""
echo "To connect Metabase to BigQuery, you'll need a service account key file."
echo ""
echo "If you haven't created a service account yet, follow these steps:"
echo ""
echo "1. Go to Google Cloud Console: https://console.cloud.google.com/"
echo "2. Navigate to IAM & Admin > Service Accounts"
echo "3. Click 'Create Service Account'"
echo "4. Name the service account 'metabase-bigquery'"
echo "5. Grant the following roles:"
echo "   - BigQuery Data Viewer"
echo "   - BigQuery Job User"
echo "6. Click 'Create Key' (JSON format)"
echo "7. Save the key file securely"
echo ""
echo "Note: Keep your service account key secure and never commit it to version control!"
echo ""

# Start Metabase
echo "===== Starting Metabase ====="
echo ""
echo "Starting Metabase container..."
docker-compose up -d

# Wait for Metabase to start
echo ""
echo "Waiting for Metabase to start (this may take a minute)..."
attempt=0
max_attempts=60

while [ $attempt -lt $max_attempts ]; do
    if curl -s http://localhost:3000 > /dev/null; then
        echo "Metabase is now running!"
        break
    fi
    attempt=$((attempt+1))
    echo -n "."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    echo ""
    echo "Metabase is taking longer than expected to start."
    echo "It may still be initializing. Please check 'docker logs metabase' for status."
fi

echo ""
echo "===== Next Steps ====="
echo ""
echo "1. Access Metabase at: http://localhost:3000"
echo "2. Complete the initial setup wizard"
echo "3. Connect to BigQuery:"
echo "   - Admin > Databases > Add database"
echo "   - Select 'Google BigQuery'"
echo "   - Enter your project ID: de-zoomcamp-project-455806"
echo "   - Paste the contents of your service account JSON key file"
echo "   - Set the Dataset ID (e.g. 'marts')"
echo ""
echo "For detailed dashboard setup instructions, refer to metabase_implementation_guide.md"
echo ""
echo "===== Useful Commands ====="
echo ""
echo "View Metabase logs: docker logs metabase"
echo "Stop Metabase:      docker-compose down"
echo "Restart Metabase:   docker-compose restart"
echo ""

exit 0
