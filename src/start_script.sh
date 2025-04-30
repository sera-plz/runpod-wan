#!/usr/bin/env bash
set -euo pipefail

# Check if directory exists and remove it or update it
if [ -d "runpod-wan" ]; then
  echo "📂 Directory already exists. Removing it first..."
  rm -rf runpod-wan
fi

echo "📥 Cloning runpod-wan…"
git clone https://github.com/atumn/runpod-wan.git

echo "📂 Moving start.sh into place…"
mv runpod-wan/src/start.sh /

echo "▶️ Running start.sh"
bash /start.sh