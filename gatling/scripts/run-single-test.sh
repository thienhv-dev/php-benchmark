#!/bin/bash

# Single Gatling Test Runner

GATLING_CONTAINER="php-benchmark-gatling"
SIMULATION=${1:-"PhpBenchmarkSimulation"}
ENDPOINT=${2:-"fast"}
USERS=${3:-50}
DURATION=${4:-60}

echo "🎯 Running Single Gatling Test"
echo "Simulation: $SIMULATION"
echo "Endpoint: $ENDPOINT"
echo "Users: $USERS"
echo "Duration: ${DURATION}s"
echo "================================"

# Wait for PHP app
echo "⏳ Checking PHP app availability..."
until docker exec "$GATLING_CONTAINER" curl -s "http://php-app/health" >/dev/null 2>&1; do
    echo "   Waiting for PHP app..."
    sleep 1
done
echo "✅ PHP app is ready"

# Run the test
echo ""
echo "🚀 Starting Gatling test..."

GATLING_BIN="/opt/gatling/gatling/bin/gatling.sh"

# Check if Gatling is installed
docker exec "$GATLING_CONTAINER" test -f "$GATLING_BIN" || {
    echo "❌ Gatling not found! Run setup first:"
    echo "bash gatling/scripts/setup-gatling.sh"
    exit 1
}

if [ "$SIMULATION" = "SingleEndpointSimulation" ]; then
    docker exec "$GATLING_CONTAINER" \
        "$GATLING_BIN" \
        -s "$SIMULATION" \
        -rf "/opt/gatling/results" \
        -Dendpoint="$ENDPOINT" \
        -Dusers="$USERS" \
        -Dduration="$DURATION"
else
    docker exec "$GATLING_CONTAINER" \
        "$GATLING_BIN" \
        -s "$SIMULATION" \
        -rf "/opt/gatling/results"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Test completed successfully!"
    echo "📊 Check results/ directory for HTML reports"
else
    echo ""
    echo "❌ Test failed - check logs for details"
fi