#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

echo "== System Information =="
python --version
pip --version
echo "PyTorch version: $(python -c 'import torch; print(torch.__version__)')"
echo "CUDA available: $(python -c 'import torch; print(torch.cuda.is_available())')"
echo "Python executable path: $(which python)"
echo "Checking SageAttention installation..."
python -c "import sageattention; print('SageAttention imported successfully')"
echo "== End System Information =="

# Set the network volume path
# Determine the network volume based on environment
# Check if /workspace exists
if [ -d "/workspace" ]; then
    NETWORK_VOLUME="/workspace"
else
    echo "Warning: /workspace does not exist"
    exit 1
fi

echo "Using NETWORK_VOLUME: $NETWORK_VOLUME"
FLAG_FILE="$NETWORK_VOLUME/.comfyui_initialized"

if [ -f "$FLAG_FILE" ]; then
  # echo "FLAG FILE FOUND"
  # echo "▶️  Starting ComfyUI"
  # # group both the main and fallback commands so they share the same log
  # mkdir -p "$NETWORK_VOLUME/${RUNPOD_POD_ID}"
  # nohup bash -c "/usr/bin/python \"$NETWORK_VOLUME\"/ComfyUI/main.py --listen 2>&1 | tee \"$NETWORK_VOLUME\"/comfyui_\"$RUNPOD_POD_ID\"_nohup.log" &

  # until curl --silent --fail "$URL" --output /dev/null; do
  #     echo "🔄  Still waiting…"
  #     sleep 2
  # done
  
  # echo "ComfyUI is UP!"  
  # echo "Initialization complete! Pod is ready to process jobs."

  # # Wait on background jobs forever
  # wait
  # Serve the API and don't shutdown the container
  if [ "$SERVE_API_LOCALLY" == "true" ]; then
      echo "runpod-worker-comfy: Starting ComfyUI"
      python /ComfyUI/main.py --disable-auto-launch --disable-metadata --listen &

      echo "runpod-worker-comfy: Starting RunPod Handler"
      python -u /rp_handler.py --rp_serve_api --rp_api_host=0.0.0.0
  else
      echo "runpod-worker-comfy: Starting ComfyUI"
      python /ComfyUI/main.py --disable-auto-launch --disable-metadata &
      
      echo "runpod-worker-comfy: Starting RunPod Handler"
      python -u /rp_handler.py
  fi
else
  echo "NO FLAG FILE FOUND – manually download the models first!"
  bash /init.sh
fi