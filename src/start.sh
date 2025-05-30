#!/usr/bin/env bash
# in case if you're running from pod, make sure to configure python to use python3.10
# apt-get update && apt-get install -y --no-install-recommends \
#    python3.10 python3.10-dev python3.10-distutils python3-pip aria2 \
#    && ln -sf /usr/bin/python3.10 /usr/bin/python \
#    && ln -sf /usr/bin/python3.10 /usr/bin/python3 \
#    && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 \
#    && ln -sf /usr/local/bin/pip /usr/bin/pip \
#    && ln -sf /usr/local/bin/pip /usr/bin/pip3 

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
  python main.py --port 3000 --use-sage-attention --listen > /workspace/logs/comfyui.log 2>&1 &
  deactivate

  echo "Starting RunPod Handler"
  python3 -u /rp_handler.py
else
  echo "Warning: /workspace does not exist"
  exit 1
fi
