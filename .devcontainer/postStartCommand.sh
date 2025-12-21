#!/usr/bin/zsh

WORKSPACE_PATH=/workspaces/typo3-devcontainer

# Start Mailpit
sudo /usr/local/share/mailpit-init.sh

# Mind the order of the services to start
sudo service cron start

# Ensure caches are clean and env vars will be loaded
slh php $WORKSPACE_PATH/vendor/bin/typo3 extension:setup
slh php $WORKSPACE_PATH/vendor/bin/typo3 cache:flush
cd $WORKSPACE_PATH && slh webserver