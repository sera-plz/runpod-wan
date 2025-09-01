#!/usr/bin/env bash

# Create workspace symlink for consistency
rm -rf /workspace && ln -s /comfywan /workspace

# Activate the ComfyUI virtual environment
source /workspace/venv/bin/activate
echo "venv info:"
echo $VIRTUAL_ENV && python -V && which python && which pip

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"
export PYTHONUNBUFFERED=true
export HF_HOME="/workspace"

cd /workspace

# Ensure ComfyUI-Manager runs in offline network mode inside the container
comfy-manager-set-mode offline || echo "worker-comfyui - Could not set ComfyUI-Manager network_mode" >&2

echo "worker-comfyui: Starting ComfyUI"
# Allow operators to tweak verbosity; default is INFO.
: "${COMFY_LOG_LEVEL:=INFO}"

# Start ComfyUI with all models baked into the image
python -u /workspace/main.py --port 3000 --use-sage-attention --base-directory /workspace --disable-auto-launch --disable-metadata --verbose "${COMFY_LOG_LEVEL}" --log-stdout &

echo "worker-comfyui: Starting RunPod Handler"
python -u /rp_handler.py
