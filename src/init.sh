#!/usr/bin/env bash

mv /ComfyUI /workspace/ComfyUI

# echo "Downloading CivitAI download script to /usr/local/bin"
# git clone "https://github.com/Hearmeman24/CivitAI_Downloader.git" || { echo "Git clone failed"; exit 1; }
# mv CivitAI_Downloader/download.py "/usr/local/bin/" || { echo "Move failed"; exit 1; }
# chmod +x "/usr/local/bin/download.py" || { echo "Chmod failed"; exit 1; }
# rm -rf CivitAI_Downloader  # Clean up the cloned repo

# pip install huggingface_hub
pip install onnxruntime-gpu
if [ "$enable_optimizations" == "true" ]; then
  echo "Downloading Triton"
  pip install triton
fi

# Change to the directory
cd /workspace/ComfyUI/custom_nodes || exit 1

# Define base paths
DIFFUSION_MODELS_DIR="/workspace/ComfyUI/models/diffusion_models"
TEXT_ENCODERS_DIR="/workspace/ComfyUI/models/text_encoders"
CLIP_VISION_DIR="/workspace/ComfyUI/models/clip_vision"
VAE_DIR="/workspace/ComfyUI/models/vae"

# Download 720p native models
echo "Downloading 720p native models..."
aria2c -x16 -s16 -d "$DIFFUSION_MODELS_DIR" -o wan2.1_i2v_720p_14B_fp16.safetensors --continue=true \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp16.safetensors
# download_model "$DIFFUSION_MODELS_DIR" "wan2.1_i2v_480p_14B_bf16.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/diffusion_models/wan2.1_i2v_480p_14B_bf16.safetensors"

aria2c -x16 -s16 -d "$DIFFUSION_MODELS_DIR" -o wan2.1_t2v_14B_fp16.safetensors --continue=true \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp16.safetensors
# download_model "$DIFFUSION_MODELS_DIR" "wan2.1_t2v_14B_bf16.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/diffusion_models/wan2.1_t2v_14B_bf16.safetensors"

# Download text encoders
aria2c -x16 -s16 -d "$TEXT_ENCODERS_DIR" -o umt5_xxl_fp16.safetensors --continue=true \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors
# download_model "$TEXT_ENCODERS_DIR" "umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

aria2c -x16 -s16 -d "$TEXT_ENCODERS_DIR" -o open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors --continue=true \
  https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors
# download_model "$TEXT_ENCODERS_DIR" "open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors" \
#   "Kijai/WanVideo_comfy" "open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors"

# Create CLIP vision directory and download models
mkdir -p "$CLIP_VISION_DIR"
aria2c -x16 -s16 -d "$CLIP_VISION_DIR" -o clip_vision_h.safetensors --continue=true \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors
# download_model "$CLIP_VISION_DIR" "clip_vision_h.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/clip_vision/clip_vision_h.safetensors"

# Download VAE
echo "Downloading VAE..."
aria2c -x16 -s16 -d "$VAE_DIR" -o Wan2_1_VAE_bf16.safetensors --continue=true \
  https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors
# download_model "$VAE_DIR" "Wan2_1_VAE_bf16.safetensors" \
#   "Kijai/WanVideo_comfy" "Wan2_1_VAE_bf16.safetensors"

aria2c -x16 -s16 -d "$VAE_DIR" -o wan_2.1_vae.safetensors --continue=true \
  https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors
# download_model "$VAE_DIR" "wan_2.1_vae.safetensors" \
#   "Comfy-Org/Wan_2.1_ComfyUI_repackaged" "split_files/vae/wan_2.1_vae.safetensors"

# Moving upscale model
echo "Moving upscale models"
mkdir -p "/workspace/ComfyUI/models/upscale_models"
if [ ! -f "/workspace/ComfyUI/models/upscale_models/4xLSDIR.pth" ]; then
    if [ -f "/4xLSDIR.pth" ]; then
        mv "/4xLSDIR.pth" "/workspace/ComfyUI/models/upscale_models/4xLSDIR.pth"
        echo "Moved 4xLSDIR.pth to the correct location."
    else
        echo "4xLSDIR.pth not found in the root directory."
    fi
else
    echo "4xLSDIR.pth already exists. Skipping."
fi

# Download film network model
echo "Downloading film network model"
if [ ! -f "/workspace/ComfyUI/models/upscale_models/film_net_fp32.pt" ]; then
  mkdir -p "/workspace/ComfyUI/models/upscale_models"
  aria2c -x16 -s16 -d "/workspace/ComfyUI/models/upscale_models" -o film_net_fp32.pt --continue=true \
    https://huggingface.co/nguu/film-pytorch/resolve/887b2c42bebcb323baf6c3b6d59304135699b575/film_net_fp32.pt
fi

echo "Finished downloading models!"

# echo "Downloading LoRAs"

# mkdir -p "/workspace/ComfyUI/models/loras" && \
# (gdown "1IfTa_Z_SSDFz7x0ootJu293qsxf19FEZ" -O "/workspace/ComfyUI/models/loras/Wan_ClothesOnOff_Trend.safetensors" || \
# echo "Download failed for Wan_ClothesOnOff_Trend.safetensors, continuing...")

# declare -A MODEL_CATEGORY_FILES=(
#     ["/workspace/ComfyUI/models/checkpoints"]="/workspace/comfyui-discord-bot/downloads/checkpoint_to_download.txt"
#     ["/workspace/ComfyUI/models/loras"]="/workspace/comfyui-discord-bot/downloads/lora_to_download.txt"
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
echo "cd /workspace" >> ~/.bashrc
echo "cd /workspace" >> ~/.bash_profile

if [ ! -d "/workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes" ]; then
    cd /workspace/ComfyUI/custom_nodes
    git clone https://github.com/kijai/ComfyUI-KJNodes.git
else
    echo "Updating KJ Nodes"
    cd /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes
    git pull
fi

# Install dependencies
pip install --no-cache-dir -r /workspace/ComfyUI/custom_nodes/ComfyUI-KJNodes/requirements.txt

touch /workspace/.comfyui_initialized

