<?php
require_once 'config.php';

header('Content-Type: application/json');

$start_time = microtime(true);
$start_memory = memory_get_usage(true);

// Route handling
$request_uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

switch ($request_uri) {
    case '/':
        echo json_encode([
            'message' => 'PHP Benchmark API',
            'endpoints' => [
                '/api/fast',
                '/api/medium', 
                '/api/slow',
                '/health'
            ]
        ]);
        break;
        
    case '/health':
        echo json_encode([
            'status' => 'healthy',
            'timestamp' => date('c'),
            'php_version' => PHP_VERSION,
            'memory_usage_mb' => round(memory_get_usage(true) / 1024 / 1024, 2)
        ]);
        break;
        
    case '/api/fast':
    case '/api/medium':
    case '/api/slow':
        require_once 'api.php';
        break;
        
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint not found']);
}

// Add performance metrics to response
$execution_time = (microtime(true) - $start_time) * 1000;
$memory_used = memory_get_usage(true) - $start_memory;

if (!headers_sent()) {
    header('X-Execution-Time: ' . round($execution_time, 3) . 'ms');
    header('X-Memory-Used: ' . round($memory_used / 1024, 2) . 'KB');
}