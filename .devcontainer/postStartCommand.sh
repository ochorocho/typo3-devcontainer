#!/usr/bin/zsh

set -e

WORKSPACE_PATH=/workspaces/typo3-devcontainer

# Start Mailpit
sudo /usr/local/share/mailpit-init.sh

# Mind the order of the services to start
sudo service cron start

# Ensure caches are clean and env vars will be loaded
slh php $WORKSPACE_PATH/vendor/bin/typo3 extension:setup
slh php $WORKSPACE_PATH/vendor/bin/typo3 cache:flush

# Ugly hack to make the webserver run, @todo: fix the binary installation
sudo rm -f /home/vscode/.santas-little-helper/bin/frankenphp

nohup bash -c "cd $WORKSPACE_PATH && slh webserver &"

# code --reuse-window .devcontainer/DEVCONTAINER-INFO.md
# code --openExternal $TYPO3_BASE_DOMAIN/typo3/

cat README.md