<?php
// Basic configuration
ini_set('display_errors', 0);
error_reporting(E_ALL);

// Performance settings
ini_set('memory_limit', '256M');
ini_set('max_execution_time', 30);

// Enable OPcache if available
if (function_exists('opcache_get_status')) {
    ini_set('opcache.enable', 1);
    ini_set('opcache.memory_consumption', 128);
    ini_set('opcache.max_accelerated_files', 4000);
}

// Set timezone
date_default_timezone_set('Asia/Ho_Chi_Minh');