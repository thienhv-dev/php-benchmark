<?php
$endpoint = basename(parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$start_time = microtime(true);

switch ($endpoint) {
    case 'fast':
        // Fast response - minimal processing
        usleep(rand(1000, 10000)); // 1-10ms
        
        $response = [
            'endpoint' => 'fast',
            'message' => 'Fast response',
            'data' => [
                'id' => rand(1, 1000),
                'value' => rand(1, 100),
                'timestamp' => date('c')
            ]
        ];
        break;
        
    case 'medium':
        // Medium response - some processing
        usleep(rand(50000, 150000)); // 50-150ms
        
        // Some CPU work
        $result = 0;
        for ($i = 0; $i < 50000; $i++) {
            $result += sqrt($i);
        }
        
        $response = [
            'endpoint' => 'medium',
            'message' => 'Medium response',
            'computation_result' => $result,
            'data' => array_map(function($i) use ($result) {
                return [
                    'id' => $i,
                    'value' => rand(1, 1000),
                    'computed' => $result / ($i + 1)
                ];
            }, range(1, 10))
        ];
        break;
        
    case 'slow':
        // Slow response - heavy processing
        usleep(rand(500000, 1500000)); // 500-1500ms
        
        // Heavy CPU work
        $result = 0;
        for ($i = 0; $i < 500000; $i++) {
            $result += sqrt($i) * sin($i);
        }
        
        // Generate large dataset
        $data = [];
        for ($i = 0; $i < 50; $i++) {
            $data[] = [
                'id' => $i,
                'value' => rand(1, 10000),
                'hash' => md5($i . microtime()),
                'computed' => $result / ($i + 1)
            ];
        }
        
        $response = [
            'endpoint' => 'slow',
            'message' => 'Slow response',
            'computation_result' => $result,
            'data' => $data
        ];
        break;
        
    default:
        http_response_code(404);
        $response = ['error' => 'Endpoint not found'];
}

// Add timing info
$processing_time = (microtime(true) - $start_time) * 1000;
$response['processing_time_ms'] = round($processing_time, 3);
$response['memory_usage_mb'] = round(memory_get_usage(true) / 1024 / 1024, 3);

echo json_encode($response, JSON_PRETTY_PRINT);