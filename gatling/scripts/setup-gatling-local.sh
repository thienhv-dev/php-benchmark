#!/bin/bash

# Alternative Gatling Setup Script - Download locally first
# This approach is more reliable for slow/unreliable connections

GATLING_CONTAINER="php-benchmark-gatling"
GATLING_VERSION="3.9.5"
GATLING_URL="https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/${GATLING_VERSION}/gatling-charts-highcharts-bundle-${GATLING_VERSION}-bundle.zip"
LOCAL_DOWNLOAD_DIR="./gatling/downloads"
LOCAL_ZIP_FILE="$LOCAL_DOWNLOAD_DIR/gatling-${GATLING_VERSION}.zip"

echo "🚀 Alternative Gatling Setup (Local Download)"
echo "Container: $GATLING_CONTAINER"
echo "Version: $GATLING_VERSION"

# Check if container is running
if ! docker ps | grep -q "$GATLING_CONTAINER"; then
    echo "❌ Container $GATLING_CONTAINER is not running"
    echo "Run: docker-compose up -d"
    exit 1
fi

# Create local download directory
mkdir -p "$LOCAL_DOWNLOAD_DIR"

# Download locally if not already present
if [ ! -f "$LOCAL_ZIP_FILE" ]; then
    echo "📥 Downloading Gatling locally..."
    if curl -L --progress-bar -o "$LOCAL_ZIP_FILE" "$GATLING_URL"; then
        echo "✅ Download completed"
    else
        echo "❌ Download failed"
        exit 1
    fi
else
    echo "📋 Using existing local download: $LOCAL_ZIP_FILE"
fi

# Verify local zip file
echo "🔍 Verifying local zip file..."
if unzip -t "$LOCAL_ZIP_FILE" >/dev/null 2>&1; then
    echo "✅ Local zip file is valid"
else
    echo "❌ Local zip file is corrupted, re-downloading..."
    rm -f "$LOCAL_ZIP_FILE"
    echo "📥 Re-downloading Gatling..."
    if curl -L --progress-bar -o "$LOCAL_ZIP_FILE" "$GATLING_URL"; then
        echo "✅ Re-download completed"
    else
        echo "❌ Re-download failed"
        exit 1
    fi
fi

# Copy to container and install
echo "📦 Copying and installing in container..."
docker exec "$GATLING_CONTAINER" bash -c "
    cd /opt/gatling &&
    echo 'Cleaning up previous installation...' &&
    rm -rf gatling-charts-highcharts-bundle-* gatling
" &&

docker cp "$LOCAL_ZIP_FILE" "$GATLING_CONTAINER":/opt/gatling/gatling.zip &&

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

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Gatling setup completed successfully!"
    echo ""
    echo "🎯 Test Gatling installation:"
    echo "docker exec $GATLING_CONTAINER /opt/gatling/gatling/bin/gatling.sh --help"
    echo ""
    echo "🚀 Run a simulation:"
    echo "bash gatling/scripts/run-single-test.sh PhpBenchmarkSimulation"
    echo ""
    echo "💡 The local download is cached in: $LOCAL_ZIP_FILE"
else
    echo ""
    echo "❌ Gatling setup failed!"
    echo "Check the container logs: docker logs $GATLING_CONTAINER"
fi