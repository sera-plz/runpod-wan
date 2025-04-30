#!/usr/bin/env bash

# Use libtcmalloc for better memory management
TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1)"
export LD_PRELOAD="${TCMALLOC}"

set -eo pipefail
set +u

API_URL="https://bulan.mn/ai"
echo "Using production API endpoint"

echo "== System Information =="
python --version
pip --version
echo "PyTorch version: $(python -c 'import torch; print(torch.__version__)')"
echo "CUDA available: $(python -c 'import torch; print(torch.cuda.is_available())')"
echo "Python executable path: $(which python)"
echo "Checking SageAttention installation..."
python -c "import sageattention; print('SageAttention imported successfully')"
echo "== End System Information =="

URL="http://127.0.0.1:8188"

# Function to report pod status
report_status() {
    local status=$1
    local details=$2

    echo "Reporting status: $details"

    curl -X POST "${API_URL}/pods/$RUNPOD_POD_ID/status" \
      -H "Content-Type: application/json" \
      -H "x-api-key: ${API_KEY}" \
      -d "{\"initialized\": $status, \"details\": \"$details\"}" \
      --silent

    echo "Status reported: $status - $details"
}
report_status false "Starting initialization"
# Set the network volume path
# Determine the network volume based on environment
# Check if /workspace exists
if [ -d "/workspace" ]; then
    NETWORK_VOLUME="/workspace"
# If not, check if /runpod-volume exists
elif [ -d "/runpod-volume" ]; then
    NETWORK_VOLUME="/runpod-volume"
# Fallback to root if neither directory exists
else
    echo "Warning: Neither /workspace nor /runpod-volume exists, falling back to root directory"
    NETWORK_VOLUME="/"
fi

echo "Using NETWORK_VOLUME: $NETWORK_VOLUME"
pip install runpod
FLAG_FILE="$NETWORK_VOLUME/.comfyui_initialized"
COMFYUI_DIR="$NETWORK_VOLUME/ComfyUI"

if [ -f "$FLAG_FILE" ]; then
  echo "FLAG FILE FOUND"
  echo "▶️  Starting ComfyUI"
  # group both the main and fallback commands so they share the same log
  mkdir -p "$NETWORK_VOLUME/${RUNPOD_POD_ID}"
  nohup bash -c "/usr/bin/python \"$NETWORK_VOLUME\"/ComfyUI/main.py --listen 2>&1 | tee \"$NETWORK_VOLUME\"/comfyui_\"$RUNPOD_POD_ID\"_nohup.log" &

  until curl --silent --fail "$URL" --output /dev/null; do
      echo "🔄  Still waiting…"
      sleep 2
  done
  
  echo "ComfyUI is UP!"  
  report_status true "Pod fully initialized and ready for processing"
  echo "Initialization complete! Pod is ready to process jobs."

  # Wait on background jobs forever
  wait
else
  echo "NO FLAG FILE FOUND – starting initial setup"
fi

# Set the target directory
CUSTOM_NODES_DIR="$NETWORK_VOLUME/ComfyUI/custom_nodes"

if [ ! -d "$COMFYUI_DIR" ]; then
    mv /ComfyUI "$COMFYUI_DIR"
else
    echo "Directory already exists, skipping move."
fi

echo "Downloading CivitAI download script to /usr/local/bin"
git clone "https://github.com/Hearmeman24/CivitAI_Downloader.git" || { echo "Git clone failed"; exit 1; }
mv CivitAI_Downloader/download.py "/usr/local/bin/" || { echo "Move failed"; exit 1; }
chmod +x "/usr/local/bin/download.py" || { echo "Chmod failed"; exit 1; }
rm -rf CivitAI_Downloader  # Clean up the cloned repo
pip install huggingface_hub
pip install onnxruntime-gpu

if [ "$enable_optimizations" == "true" ]; then
  echo "Downloading Triton"
  pip install triton
fi


# Change to the directory
cd "$CUSTOM_NODES_DIR" || exit 1

# Define base paths
DIFFUSION_MODELS_DIR="$NETWORK_VOLUME/ComfyUI/models/diffusion_models"
TEXT_ENCODERS_DIR="$NETWORK_VOLUME/ComfyUI/models/text_encoders"
CLIP_VISION_DIR="$NETWORK_VOLUME/ComfyUI/models/clip_vision"
VAE_DIR="$NETWORK_VOLUME/ComfyUI/models/vae"

# Download 720p native models
echo "Downloading 720p native models..."
aria2c -x16 -s16 -d "$DIFFUSION_MODELS_DIR" -o wan2.1_i2v_720p_14B_fp16.safetensors \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp16.safetensors
# download_model "$DIFFUSION_MODELS_DIR" "wan2.1_i2v_480p_14B_bf16.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/diffusion_models/wan2.1_i2v_480p_14B_bf16.safetensors"

aria2c -x16 -s16 -d "$DIFFUSION_MODELS_DIR" -o wan2.1_t2v_14B_fp16.safetensors \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp16.safetensors
# download_model "$DIFFUSION_MODELS_DIR" "wan2.1_t2v_14B_bf16.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/diffusion_models/wan2.1_t2v_14B_bf16.safetensors"

# Download text encoders
aria2c -x16 -s16 -d "$TEXT_ENCODERS_DIR" -o umt5_xxl_fp16.safetensors \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors
# download_model "$TEXT_ENCODERS_DIR" "umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

aria2c -x16 -s16 -d "$TEXT_ENCODERS_DIR" -o open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors
  https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors
# download_model "$TEXT_ENCODERS_DIR" "open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors" \
#   "Kijai/WanVideo_comfy" "open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors"

# Create CLIP vision directory and download models
mkdir -p "$CLIP_VISION_DIR"
aria2c -x16 -s16 -d "$CLIP_VISION_DIR" -o clip_vision_h.safetensors \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors
# download_model "$CLIP_VISION_DIR" "clip_vision_h.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/clip_vision/clip_vision_h.safetensors"

# Download VAE
echo "Downloading VAE..."
aria2c -x16 -s16 -d "$VAE_DIR" -o Wan2_1_VAE_bf16.safetensors \
  https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors
# download_model "$VAE_DIR" "Wan2_1_VAE_bf16.safetensors" \
#   "Kijai/WanVideo_comfy" "Wan2_1_VAE_bf16.safetensors"

aria2c -x16 -s16 -d "$VAE_DIR" -o wan_2.1_vae.safetensors \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
# download_model "$VAE_DIR" "wan_2.1_vae.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/vae/wan_2.1_vae.safetensors"

# Download upscale model
echo "Downloading upscale models"
mkdir -p "$NETWORK_VOLUME/ComfyUI/models/upscale_models"
if [ ! -f "$NETWORK_VOLUME/ComfyUI/models/upscale_models/4xLSDIR.pth" ]; then
    if [ -f "/4xLSDIR.pth" ]; then
        mv "/4xLSDIR.pth" "$NETWORK_VOLUME/ComfyUI/models/upscale_models/4xLSDIR.pth"
        echo "Moved 4xLSDIR.pth to the correct location."
    else
        echo "4xLSDIR.pth not found in the root directory."
    fi
else
    echo "4xLSDIR.pth already exists. Skipping."
fi

# Download film network model
echo "Downloading film network model"
if [ ! -f "$NETWORK_VOLUME/ComfyUI/models/upscale_models/film_net_fp32.pt" ]; then
  mkdir -p "$NETWORK_VOLUME/ComfyUI/models/upscale_models"
  aria2c -x16 -s16 -d "$NETWORK_VOLUME/ComfyUI/models/upscale_models" -o film_net_fp32.pt \
    https://huggingface.co/nguu/film-pytorch/resolve/887b2c42bebcb323baf6c3b6d59304135699b575/film_net_fp32.pt
fi

echo "Finished downloading models!"

echo "Downloading LoRAs"

mkdir -p "$NETWORK_VOLUME/ComfyUI/models/loras" && \
(gdown "1IfTa_Z_SSDFz7x0ootJu293qsxf19FEZ" -O "$NETWORK_VOLUME/ComfyUI/models/loras/Wan_ClothesOnOff_Trend.safetensors" || \
echo "Download failed for Wan_ClothesOnOff_Trend.safetensors, continuing...")

# declare -A MODEL_CATEGORY_FILES=(
#     ["$NETWORK_VOLUME/ComfyUI/models/checkpoints"]="$NETWORK_VOLUME/comfyui-discord-bot/downloads/checkpoint_to_download.txt"
#     ["$NETWORK_VOLUME/ComfyUI/models/loras"]="$NETWORK_VOLUME/comfyui-discord-bot/downloads/lora_to_download.txt"
# )

# # Ensure directories exist and download models
# for TARGET_DIR in "${!MODEL_CATEGORY_FILES[@]}"; do
#     CONFIG_FILE="${MODEL_CATEGORY_FILES[$TARGET_DIR]}"

#     # Skip if the file doesn't exist
#     if [ ! -f "$CONFIG_FILE" ]; then
#         echo "Skipping downloads for $TARGET_DIR (file $CONFIG_FILE not found)"
#         continue
#     fi

#     # Read comma-separated model IDs from the file
#     MODEL_IDS_STRING=$(cat "$CONFIG_FILE")

#     # Skip if the file is empty or contains placeholder text
#     if [ -z "$MODEL_IDS_STRING" ] || [ "$MODEL_IDS_STRING" == "replace_with_ids" ]; then
#         echo "Skipping downloads for $TARGET_DIR ($CONFIG_FILE is empty or contains placeholder)"
#         continue
#     fi

#     mkdir -p "$TARGET_DIR"
#     IFS=',' read -ra MODEL_IDS <<< "$MODEL_IDS_STRING"

#     for MODEL_ID in "${MODEL_IDS[@]}"; do
#         echo "Downloading model: $MODEL_ID to $TARGET_DIR"
#         (cd "$TARGET_DIR" && download.py --model "$MODEL_ID") || {
#             echo "ERROR: Failed to download model $MODEL_ID to $TARGET_DIR, continuing with next model..."
#         }
#     done
# done

# Workspace as main working directory
echo "cd $NETWORK_VOLUME" >> ~/.bashrc
echo "cd $NETWORK_VOLUME" >> ~/.bash_profile

if [ ! -d "$NETWORK_VOLUME/ComfyUI/custom_nodes/ComfyUI-KJNodes" ]; then
    cd $NETWORK_VOLUME/ComfyUI/custom_nodes
    git clone https://github.com/kijai/ComfyUI-KJNodes.git
else
    echo "Updating KJ Nodes"
    cd $NETWORK_VOLUME/ComfyUI/custom_nodes/ComfyUI-KJNodes
    git pull
fi

# Install dependencies
pip install --no-cache-dir -r $NETWORK_VOLUME/ComfyUI/custom_nodes/ComfyUI-KJNodes/requirements.txt
echo "Starting ComfyUI"
touch "$FLAG_FILE"
mkdir -p "$NETWORK_VOLUME/${RUNPOD_POD_ID}"
nohup bash -c "/usr/bin/python \"$NETWORK_VOLUME\"/ComfyUI/main.py --listen 2>&1 | tee \"$NETWORK_VOLUME\"/comfyui_\"$RUNPOD_POD_ID\"_nohup.log" &
COMFY_PID=$!

until curl --silent --fail "$URL" --output /dev/null; do
    echo "🔄  Still waiting…"
    sleep 2
done

echo "ComfyUI is UP"

report_status true "Pod fully initialized and ready for processing"
echo "Initialization complete! Pod is ready to process jobs."
# Wait for both processes
wait $COMFY_PID