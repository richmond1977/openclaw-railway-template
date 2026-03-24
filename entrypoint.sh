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
exec gosu openclaw node src/server.js
