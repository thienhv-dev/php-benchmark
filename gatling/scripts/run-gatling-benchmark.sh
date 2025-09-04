#!/bin/bash

# Gatling Benchmark Runner Script for PHP Application

GATLING_CONTAINER="php-benchmark-gatling"
TARGET_URL=${1:-"http://php-app"}
RESULTS_DIR="/opt/gatling/results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚀 Starting Gatling Benchmark Suite"
echo "Target: $TARGET_URL"
echo "Time: $(date)"
echo "================================"

# Check if Gatling is installed
echo "🔍 Checking Gatling installation..."
if ! docker exec "$GATLING_CONTAINER" test -f "/opt/gatling/gatling/bin/gatling.sh"; then
    echo "❌ Gatling not found! Installing..."
    bash gatling/scripts/setup-gatling.sh
    if [ $? -ne 0 ]; then
        echo "❌ Gatling setup failed! Exiting..."
        exit 1
    fi
fi
echo "✅ Gatling is ready"

# Function to run Gatling simulation
run_gatling_simulation() {
    local simulation=$1
    local description=$2
    local extra_opts=$3
    
    echo ""
    echo "📊 Running $description..."
    
    docker exec "$GATLING_CONTAINER" \
        /opt/gatling/gatling/bin/gatling.sh \
        -s "$simulation" \
        -rf "$RESULTS_DIR" \
        $extra_opts
        
    if [ $? -eq 0 ]; then
        echo "✅ $description completed successfully"
    else
        echo "❌ $description failed"
    fi
}

# Wait for PHP app to be ready
echo "⏳ Waiting for PHP app..."
until docker exec "$GATLING_CONTAINER" curl -s "$TARGET_URL/health" >/dev/null 2>&1; do
    echo "   Waiting for PHP app to be ready..."
    sleep 2
done
echo "✅ PHP app is ready"

# Run benchmark suite
echo ""
echo "🎯 Starting Gatling Benchmark Suite"

# 1. Comprehensive load test
run_gatling_simulation "PhpBenchmarkSimulation" "Comprehensive Load Test"

# 2. Individual endpoint tests
for endpoint in "fast" "medium" "slow"; do
    run_gatling_simulation "SingleEndpointSimulation" "$endpoint Endpoint Test" \
        "-Dendpoint=$endpoint -Dusers=100 -Dduration=60"
done

# 3. Stress test (optional - can be heavy)
read -p "🔥 Run stress test? This will generate high load (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "⚡ Running stress test - this may take several minutes..."
    run_gatling_simulation "StressTestSimulation" "Stress Test"
else
    echo "⏭️  Skipping stress test"
fi

echo ""
echo "🎉 Gatling Benchmark Suite completed!"
echo "📊 Results saved in: $RESULTS_DIR"
echo "💡 View HTML reports in the results directory"

# Generate summary
echo ""
echo "📈 Generating summary report..."
generate_gatling_summary() {
    local summary_file="/results/gatling_summary_$TIMESTAMP.txt"
    
    cat > "$summary_file" << EOF
===============================================
🚀 Gatling Benchmark Summary
===============================================
Generated: $(date)
Target: $TARGET_URL

Test Results:
- Comprehensive Load Test: Check detailed HTML reports
- Single Endpoint Tests: Individual performance metrics
- Stress Test: System limits and breaking points

Key Metrics to Review:
- Response Time Percentiles (50th, 95th, 99th)
- Requests per Second (RPS)
- Error Rate
- Response Time Distribution

HTML Reports Location: $RESULTS_DIR
===============================================
EOF

    echo "📄 Summary saved: $summary_file"
}

generate_gatling_summary

echo ""
echo "🔍 To view detailed reports:"
echo "   1. Check the results/ directory for HTML reports"
echo "   2. Open index.html files in your browser"
echo "   3. Review response time charts and statistics"