#!/usr/bin/env bash

# in case if you're running from pod, make sure to configure python to use python3.10
# apt-get update && apt-get install -y --no-install-recommends \
#    python3.10 python3.10-dev python3.10-distutils python3-pip aria2 \
#    && ln -sf /usr/bin/python3.10 /usr/bin/python \
#    && ln -sf /usr/bin/python3.10 /usr/bin/python3 \
#    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 \
#    && ln -sf /usr/local/bin/pip /usr/bin/pip \
#    && ln -sf /usr/local/bin/pip /usr/bin/pip3 

# Check if /runpod-volume exists
if [ -d "/runpod-volume" ]; then  
  echo "Starting ComfyUI API"
  source /runpod-volume/venv/bin/activate
  # Use libtcmalloc for better memory management
  TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
  export LD_PRELOAD="${TCMALLOC}"
  export PYTHONUNBUFFERED=true
  export HF_HOME="/runpod-volume"
  cd /runpod-volume/comfywan
  # python main.py --port 3000 --use-sage-attention --listen > /runpod-volume/logs/comfyui.log 2>&1 &
  python main.py --port 3000 --use-sage-attention --output-directory /runpod-volume/comfywan/output --preview-method auto
  deactivate

  echo "Starting RunPod Handler"
  python3 -u /rp_handler.py
else
  echo "Warning: /runpod-volume does not exist"
  exit 1
fi
