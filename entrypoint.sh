#!/bin/bash
set -e
chown -R openclaw:openclaw /data
chmod 700 /data
if [ ! -d /data/.linuxbrew ]; then
  cp -a /home/linuxbrew/.linuxbrew /data/.linuxbrew
fi
rm -rf /home/linuxbrew/.linuxbrew
ln -sfn /data/.linuxbrew /home/linuxbrew/.linuxbrew
gosu openclaw python3 -c "
import json, os
config_path = '/data/.openclaw/openclaw.json'
if os.path.exists(config_path):
    with open(config_path, 'r') as f:
        config = json.load(f)
    if 'plugins' not in config:
        config['plugins'] = {}
    config['plugins']['allow'] = ['line']
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    print('plugins.allow set to [line]')
" || true
# Install business admin skills
SKILL_DIR="${OPENCLAW_WORKSPACE_DIR:-/data/workspace}/skills"
mkdir -p "$SKILL_DIR"
gosu openclaw sh -c "
  cd '$SKILL_DIR' && \
  npx clawhub@latest install imap-smtp-email && \
  npx clawhub@latest install caldav-calendar && \
  npx clawhub@latest install trello && \
  npx clawhub@latest install word-docx && \
  npx clawhub@latest install ontology && \
  npx clawhub@latest install agent-browser && \
  npx clawhub@latest install api-gateway && \
  npx clawhub@latest install obsidian && \
  npx clawhub@latest install self-improving-proactive-agent
" || echo "Some skills failed to install, continuing..."
exec gosu openclaw node src/server.js
