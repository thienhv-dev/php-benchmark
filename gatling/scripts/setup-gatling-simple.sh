#!/bin/bash

# Simple Gatling Setup - Mock Installation for Demo Purposes
# This creates a demonstration setup without downloading the full Gatling distribution

GATLING_CONTAINER="php-benchmark-gatling"

echo "🚀 Setting up Demo Gatling Environment"
echo "Container: $GATLING_CONTAINER"

# Check if container is running
if ! docker ps | grep -q "$GATLING_CONTAINER"; then
    echo "❌ Container $GATLING_CONTAINER is not running"
    echo "Run: docker-compose up -d"
    exit 1
fi

echo "📦 Setting up demo Gatling environment..."

# Create a mock Gatling structure for demonstration
docker exec "$GATLING_CONTAINER" bash -c "
    mkdir -p /opt/gatling/gatling/bin &&
    mkdir -p /opt/gatling/gatling/conf &&
    mkdir -p /opt/gatling/gatling/lib &&
    
    # Create a mock gatling.sh script that shows what would happen
    cat > /opt/gatling/gatling/bin/gatling.sh << 'EOF'
#!/bin/bash

echo '==============================================='
echo '🚀 Gatling Load Testing Framework'
echo '==============================================='
echo 'Version: 3.9.5 (Demo Mode)'
echo 'Target: http://php-app'
echo ''

# Check arguments
SIMULATION=\$2
if [ \"\$1\" = \"-s\" ] && [ -n \"\$SIMULATION\" ]; then
    echo \"📊 Running simulation: \$SIMULATION\"
    echo ''
    
    # Simulate different test outputs based on simulation name
    case \$SIMULATION in
        'PhpBenchmarkSimulation')
            echo '🎯 Comprehensive Load Test Results:'
            echo '   ✅ Fast Endpoint: 850 RPS, 99th percentile: 45ms'
            echo '   ✅ Medium Endpoint: 180 RPS, 99th percentile: 250ms'
            echo '   ✅ Slow Endpoint: 25 RPS, 99th percentile: 1.8s'
            echo '   ✅ Mixed Workload: 95.2% success rate'
            ;;
        'SingleEndpointSimulation')
            ENDPOINT=\$(echo \"\$@\" | grep -o 'endpoint=[^ ]*' | cut -d= -f2)
            USERS=\$(echo \"\$@\" | grep -o 'users=[^ ]*' | cut -d= -f2)
            echo \"🎯 Single Endpoint Test Results (\${ENDPOINT:-fast})\"
            echo \"   👥 Users: \${USERS:-50}\"
            echo '   ✅ Response Time: P50=25ms, P95=89ms, P99=156ms'
            echo '   ✅ Success Rate: 98.7%'
            ;;
        'StressTestSimulation')
            echo '🔥 Stress Test Results:'
            echo '   ⚡ Peak Load: 1200 concurrent users'
            echo '   ✅ Breaking Point: ~1500 concurrent users'
            echo '   ⚠️  Error Rate increases above 1000 users'
            echo '   📈 System handles 750 users smoothly'
            ;;
        *)
            echo \"❓ Unknown simulation: \$SIMULATION\"
            ;;
    esac
    
    echo ''
    echo '📊 Detailed Results:'
    echo '   - Generating HTML Report...'
    
    # Generate actual HTML report
    bash gatling/scripts/generate-report.sh \$SIMULATION \$ENDPOINT
    
    echo '   - Raw Data: /opt/gatling/results/simulation-data.log'
    echo ''
    echo '✅ Simulation completed successfully!'
    echo ''
    echo '💡 Note: This is a demo version. For production use:'
    echo '   bash gatling/scripts/setup-gatling-local.sh'
    
else
    echo 'Usage: gatling.sh -s <SimulationClass> [options]'
    echo ''
    echo 'Available Simulations:'
    echo '  - PhpBenchmarkSimulation'
    echo '  - SingleEndpointSimulation'  
    echo '  - StressTestSimulation'
    echo ''
    echo 'Examples:'
    echo '  gatling.sh -s PhpBenchmarkSimulation'
    echo '  gatling.sh -s SingleEndpointSimulation -Dendpoint=fast -Dusers=100'
    echo ''
fi
EOF

    chmod +x /opt/gatling/gatling/bin/gatling.sh &&
    echo '✅ Demo Gatling environment created!'
"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Demo Gatling setup completed!"
    echo ""
    echo "🎯 Test the demo installation:"
    echo "docker exec $GATLING_CONTAINER /opt/gatling/gatling/bin/gatling.sh --help"
    echo ""
    echo "🚀 Run demo simulations:"
    echo "bash gatling/scripts/run-single-test.sh PhpBenchmarkSimulation"
    echo "bash gatling/scripts/run-single-test.sh SingleEndpointSimulation fast 100 60"
    echo ""
    echo "📝 Note: This is a demonstration version that shows expected results."
    echo "   For actual load testing, use: bash gatling/scripts/setup-gatling-local.sh"
else
    echo ""
    echo "❌ Demo setup failed!"
fi