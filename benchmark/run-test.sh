#!/bin/bash

# Simple Apache Benchmark script for PHP testing

TARGET_URL=${1:-"http://php-app"}
RESULTS_DIR="/results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "🚀 Starting PHP Apache Benchmark"
echo "Target: $TARGET_URL"
echo "Time: $(date)"
echo "================================"

# Create results directory
mkdir -p "$RESULTS_DIR"

# Test configurations: requests:concurrency
CONFIGS=(
    "1000:10"
    "5000:50" 
    "10000:100"
    "20000:200"
)

# Test endpoints
ENDPOINTS=("api/fast" "api/medium" "api/slow")

# Function to run single test
run_test() {
    local endpoint=$1
    local requests=$2
    local concurrency=$3
    local output_file=$4
    
    echo "📊 Testing /$endpoint - $requests requests, $concurrency concurrency"
    
    ab -n "$requests" -c "$concurrency" -k \
       -H "Accept: application/json" \
       -g "$output_file.dat" \
       "$TARGET_URL/$endpoint" > "$output_file.txt" 2>&1
    
    # Extract key metrics
    if [ -f "$output_file.txt" ]; then
        rps=$(grep "Requests per second" "$output_file.txt" | awk '{print $4}')
        mean_time=$(grep "Time per request.*mean" "$output_file.txt" | head -1 | awk '{print $4}')
        failed=$(grep "Failed requests" "$output_file.txt" | awk '{print $3}')
        
        echo "   RPS: $rps, Mean: ${mean_time}ms, Failed: $failed"
        echo "$endpoint,$requests,$concurrency,$rps,$mean_time,$failed" >> "$RESULTS_DIR/summary_$TIMESTAMP.csv"
    else
        echo "   ❌ Test failed"
    fi
}

# Initialize summary file
echo "endpoint,requests,concurrency,rps,mean_time_ms,failed_requests" > "$RESULTS_DIR/summary_$TIMESTAMP.csv"

# Wait for PHP app to be ready
echo "⏳ Waiting for PHP app..."
until curl -s "$TARGET_URL/health" >/dev/null 2>&1; do
    sleep 1
done
echo "✅ PHP app is ready"

# Run tests for each endpoint and configuration
for endpoint in "${ENDPOINTS[@]}"; do
    echo ""
    echo "🎯 Testing endpoint: /$endpoint"
    
    for config in "${CONFIGS[@]}"; do
        IFS=':' read -r requests concurrency <<< "$config"
        
        output_file="$RESULTS_DIR/${endpoint//\//_}_${requests}_${concurrency}_$TIMESTAMP"
        run_test "$endpoint" "$requests" "$concurrency" "$output_file"
        
        # Cool down between tests
        sleep 2
    done
done

echo ""
echo "🎉 Benchmark completed!"
echo "📊 Results saved in: $RESULTS_DIR"
echo "📈 Summary: $RESULTS_DIR/summary_$TIMESTAMP.csv"

# Generate simple report
generate_report() {
    local summary_file="$RESULTS_DIR/summary_$TIMESTAMP.csv"
    local report_file="$RESULTS_DIR/report_$TIMESTAMP.html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>PHP Benchmark Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #007bff; color: white; padding: 20px; border-radius: 5px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: center; }
        th { background: #f2f2f2; }
        .fast { background: #d4edda; }
        .medium { background: #fff3cd; }
        .slow { background: #f8d7da; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🚀 PHP Apache Benchmark Report</h1>
        <p>Generated: $(date)</p>
    </div>
    
    <h2>📊 Results Summary</h2>
    <table>
        <tr>
            <th>Endpoint</th>
            <th>Requests</th>
            <th>Concurrency</th>
            <th>RPS</th>
            <th>Mean Time (ms)</th>
            <th>Failed</th>
        </tr>
EOF

    # Add data rows
    while IFS=',' read -r endpoint requests concurrency rps mean_time failed; do
        if [ "$endpoint" != "endpoint" ]; then # Skip header
            case $endpoint in
                "api/fast") class="fast" ;;
                "api/medium") class="medium" ;;
                "api/slow") class="slow" ;;
                *) class="" ;;
            esac
            
            echo "        <tr class=\"$class\">" >> "$report_file"
            echo "            <td>/$endpoint</td>" >> "$report_file"
            echo "            <td>$requests</td>" >> "$report_file"
            echo "            <td>$concurrency</td>" >> "$report_file"
            echo "            <td>$rps</td>" >> "$report_file"
            echo "            <td>$mean_time</td>" >> "$report_file"
            echo "            <td>$failed</td>" >> "$report_file"
            echo "        </tr>" >> "$report_file"
        fi
    done < "$summary_file"
    
    cat >> "$report_file" << EOF
    </table>
    
    <h2>📈 Analysis</h2>
    <div>
        <h3>Performance Summary:</h3>
        <ul>
            <li><strong>Fast endpoint:</strong> Designed for &lt;10ms response time</li>
            <li><strong>Medium endpoint:</strong> Moderate processing ~100ms</li>
            <li><strong>Slow endpoint:</strong> Heavy processing &gt;500ms</li>
        </ul>
    </div>
</body>
</html>
EOF

    echo "📄 HTML Report: $report_file"
}

generate_report