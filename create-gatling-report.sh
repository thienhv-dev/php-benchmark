#!/bin/bash

# Quick script to generate Gatling HTML reports
# Usage: bash create-gatling-report.sh [SimulationName] [endpoint]

SIMULATION=${1:-"PhpBenchmarkSimulation"}
ENDPOINT=${2:-"fast"}

echo "🚀 Creating Gatling HTML Report"
echo "Simulation: $SIMULATION"
if [ "$ENDPOINT" != "fast" ]; then
    echo "Endpoint: $ENDPOINT"
fi

bash gatling/scripts/generate-report.sh "$SIMULATION" "$ENDPOINT"

echo ""
echo "✅ Report created! Open with:"
echo "open results/latest-gatling-report.html"