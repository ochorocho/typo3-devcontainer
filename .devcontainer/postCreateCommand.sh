#!/usr/bin/zsh

set -xe

sudo chmod a+x "$(pwd)"

if [ "$(ls -A $WORKSPACE_PATH)" ]; then
    echo "The folder $WORKSPACE_PATH is not empty, skipping Santa's Little Helper setup."
    exit 0
else
    SLH_USERNAME=ochorocho SLH_HOOK_CREATE=1 SLH_COMMIT_TEMPLATE="/home/vscode/.santas-little-helper/gitmessage.txt" slh core:setup $WORKSPACE_PATH --no-interaction
fi

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
