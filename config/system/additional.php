<?php

$GLOBALS['TYPO3_CONF_VARS'] = array_replace_recursive($GLOBALS['TYPO3_CONF_VARS'], [
    // This mail configuration sends all emails to mailpit
    'MAIL' => [
        'transport' => 'smtp',
        'transport_smtp_encrypt' => false,
        'transport_smtp_server' => '127.0.0.1:1025',
        'defaultMailFromAddress' => 'info@example.com'
    ],
    'SYS' => [
        'devIPmask' => '',
        'displayErrors' => 1,
        'exceptionalErrors' => 4096,
        'reverseProxyIP' => '*',
        'reverseProxyHeaderMultiValue' => 'first'
    ],
]);
