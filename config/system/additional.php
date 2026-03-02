<?php

$GLOBALS['TYPO3_CONF_VARS'] = array_replace_recursive($GLOBALS['TYPO3_CONF_VARS'], [
    'DB' => [
        'Connections' => [
            'Default' => [
                'charset' => 'utf8mb4',
                'driver' => 'mysqli',
                'dbname' => getenv('MARIADB_DATABASE') ?: 'typo3',
                'host' => '127.0.0.1',
                'port' => 3306,
                'user' => getenv('MARIADB_USER') ?: 'typo3',
                'password' => getenv('MARIADB_PASSWORD') ?: 'typo3',
            ],
        ],
    ],
    // This mail configuration sends all emails to Mailpit
    'MAIL' => [
        'transport' => 'smtp',
        'transport_smtp_encrypt' => false,
        'transport_smtp_server' => '127.0.0.1:1025',
        'defaultMailFromAddress' => 'info@example.com',
    ],
    'SYS' => [
        'devIPmask' => '',
        'displayErrors' => 1,
        'exceptionalErrors' => 4096,
        'reverseProxyIP' => '*',
        'reverseProxyHeaderMultiValue' => 'first',
    ],
]);
