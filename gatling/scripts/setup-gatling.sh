#!/bin/bash

# Manual Gatling Setup Script
# This script helps set up Gatling manually in the container

GATLING_CONTAINER="php-benchmark-gatling"
GATLING_VERSION="3.9.5"
GATLING_URL="https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/${GATLING_VERSION}/gatling-charts-highcharts-bundle-${GATLING_VERSION}-bundle.zip"

echo "🚀 Setting up Gatling in container..."
echo "Container: $GATLING_CONTAINER"
echo "Version: $GATLING_VERSION"

# Check if container is running
if ! docker ps | grep -q "$GATLING_CONTAINER"; then
    echo "❌ Container $GATLING_CONTAINER is not running"
    echo "Run: docker-compose up -d"
    exit 1
fi

echo "📥 Downloading and installing Gatling..."

# Function to check file integrity
check_zip_integrity() {
    docker exec "$GATLING_CONTAINER" bash -c "
        cd /opt/gatling &&
        if unzip -t gatling.zip >/dev/null 2>&1; then
            echo 'ZIP file is valid'
            return 0
        else
            echo 'ZIP file is corrupted'
            return 1
        fi
    "
}

# Download and install with retry logic
for attempt in 1 2 3; do
    echo "Attempt $attempt/3: Downloading Gatling..."
    
    docker exec "$GATLING_CONTAINER" bash -c "
        cd /opt/gatling &&
        echo 'Cleaning up previous attempts...' &&
        rm -rf gatling.zip gatling-charts-highcharts-bundle-* gatling &&
        echo 'Downloading Gatling (attempt $attempt)...' &&
        wget --timeout=30 --tries=2 -O gatling.zip '$GATLING_URL' &&
        ls -la gatling.zip
    "
    
    if check_zip_integrity; then
        echo "✅ Download successful, extracting..."
        docker exec "$GATLING_CONTAINER" bash -c "
            cd /opt/gatling &&
            echo 'Extracting...' &&
            unzip -q gatling.zip &&
            echo 'Setting up...' &&
            mv gatling-charts-highcharts-bundle-* gatling &&
            chmod +x gatling/bin/gatling.sh &&
            echo 'Cleaning up...' &&
            rm gatling.zip &&
            echo 'Installation complete!'
        "
        break
    else
        echo "❌ Download failed or file corrupted on attempt $attempt"
        if [ $attempt -eq 3 ]; then
            echo "❌ All download attempts failed!"
            exit 1
        fi
        echo "Retrying in 5 seconds..."
        sleep 5
    fi
done

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Gatling setup completed successfully!"
    echo ""
    echo "🎯 Test Gatling installation:"
    echo "docker exec $GATLING_CONTAINER /opt/gatling/gatling/bin/gatling.sh --help"
    echo ""
    echo "🚀 Run a simulation:"
    echo "bash gatling/scripts/run-single-test.sh PhpBenchmarkSimulation"
else
    echo ""
    echo "❌ Gatling setup failed!"
    echo "Check the container logs: docker logs $GATLING_CONTAINER"
fi