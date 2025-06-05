#!/usr/bin/env bash

# Check if /runpod-volume exists
if [ -d "/runpod-volume" ]; then
  echo "Symlinking files from Network Volume"
  rm -rf /workspace && ln -s /runpod-volume /workspace
  source /workspace/venv/bin/activate
  echo "venv info:"
  echo $VIRTUAL_ENV && python -V && which python && which pip
  # Use libtcmalloc for better memory management
  TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
  export LD_PRELOAD="${TCMALLOC}"
  export PYTHONUNBUFFERED=true
  export HF_HOME="/workspace"
  cd /workspace/comfywan
  python main.py --port 3000 --use-sage-attention > /workspace/logs/comfywan.log 2>&1 &
  deactivate

  echo "Starting RunPod Handler"
  python -u /rp_handler.py
else
  echo "Warning: /runpod-volume does not exist"
  exit 1
fi
