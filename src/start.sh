#!/usr/bin/env bash

# Check if /workspace exists
if [ -d "/workspace" ]; then  
  echo "Starting ComfyUI API"
  source /workspace/venv/bin/activate
  # Use libtcmalloc for better memory management
  TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
  export LD_PRELOAD="${TCMALLOC}"
  export PYTHONUNBUFFERED=true
  export HF_HOME="/workspace"
  cd /workspace/comfywan
  python main.py --port 3000 --listen > /workspace/logs/comfyui.log 2>&1 &
  deactivate

  echo "Starting RunPod Handler"
  python3 -u /rp_handler.py
else
  echo "Warning: /workspace does not exist"
  exit 1
fi
