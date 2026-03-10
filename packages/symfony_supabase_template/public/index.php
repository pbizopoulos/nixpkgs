<?php

use App\Kernel;

require_once dirname(__DIR__).'/vendor/autoload_runtime.php';

return function (array $context) {
    if (isset($_SERVER['APP_CACHE_DIR'])) {
        $_ENV['APP_CACHE_DIR'] = $_SERVER['APP_CACHE_DIR'];
    }
    if (isset($_SERVER['APP_LOG_DIR'])) {
        $_ENV['APP_LOG_DIR'] = $_SERVER['APP_LOG_DIR'];
    }
    return new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG']);
};
