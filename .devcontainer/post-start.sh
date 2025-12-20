#!/usr/bin/zsh

WORKSPACE_PATH=/workspaces/typo3-devcontainer

sudo chmod a+x "$(pwd)"

if [ -z "$(ls -A $WORKSPACE_PATH)" ]; then
    echo "The folder $WORKSPACE_PATH is not empty, skipping Santa's Little Helper setup."
    exit 1
else
    SLH_USERNAME=ochorocho SLH_HOOK_CREATE=1 SLH_COMMIT_TEMPLATE="/home/vscode/.santas-little-helper/gitmessage.txt" slh core:setup /workspace --no-interaction
fi

# Add composer bin directory to PATH
# so all commands are globally available
echo "export PATH=$WORKSPACE_PATH/bin:\$PATH" >> ~/.bashrc

# Dynamically set TYPO3_BASE_DOMAIN depending on the environment (local or codespaces)
if [[ -n "$CODESPACE_NAME" ]]; then
  baseDomain="export TYPO3_BASE_DOMAIN=https://$CODESPACE_NAME-8888.app.github.dev"
  echo "$baseDomain" >> ~/.zshrc
else
  baseDomain="export TYPO3_BASE_DOMAIN=http://127.0.0.1:8888"
  echo "$baseDomain" >> ~/.zshrc
fi

# Add scheduler cron
echo "* * * * * root /usr/local/bin/slh php $WORKSPACE_PATH/vendor/bin/typo3 scheduler:run > /proc/1/fd/1 2>/proc/1/fd/2" | sudo tee /etc/cron.d/typo3-scheduler
sudo chmod 0644 /etc/cron.d/typo3-scheduler

# Start Mailpit
sudo /usr/local/share/mailpit-init.sh

# Mind the order of the services to start
sudo service cron start

# Ensure caches are clean and env vars will be loaded
slh php $WORKSPACE_PATH/vendor/bin/typo3 extension:setup
slh php $WORKSPACE_PATH/vendor/bin/typo3 cache:flush
cd $WORKSPACE_PATH && slh webserver