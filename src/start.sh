#!/usr/bin/env bash

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
  echo "Starting ComfyUI API"
  source /workspace/venv/bin/activate
  # Use libtcmalloc for better memory management
  TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
  export LD_PRELOAD="${TCMALLOC}"
  export PYTHONUNBUFFERED=true
  export HF_HOME="/workspace"
  cd /workspace/ComfyUI
  python main.py --port 3000 > /workspace/logs/comfyui.log 2>&1 &
  deactivate

  echo "Starting RunPod Handler"
  python3 -u /rp_handler.py
else
  echo "Warning: /workspace does not exist"
  exit 1
fi
