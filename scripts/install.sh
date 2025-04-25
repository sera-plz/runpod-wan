#!/usr/bin/env bash
echo "Deleting ComfyUI"
rm -rf /workspace/ComfyUI

echo "Deleting venv"
rm -rf /workspace/venv

cd /workspace
echo "Cloning ComfyUI repo to /workspace"
git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git
echo "Cloning WAN2.1 repo to /workspace"
git clone https://github.com/Wan-Video/Wan2.1.git

echo "Installing Ubuntu updates"
apt update
apt -y upgrade

echo "Creating and activating venv"
python -m venv /workspace/venv
source /workspace/venv/bin/activate

# echo "Installing Torch"
# pip3 install --no-cache-dir torch==2.5.1 torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# echo "Installing xformers"
# pip3 install --no-cache-dir xformers==0.0.29.post1 --index-url https://download.pytorch.org/whl/cu121

echo "Installing WAN2.1"
cd /workspace/Wan2.1
pip install -r requirements.txt

echo "Installing ComfyUI"
cd /workspace/ComfyUI
pip3 install -r requirements.txt

echo "Installing ComfyUI Manager"
git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
cd custom_nodes/ComfyUI-Manager
pip3 install -r requirements.txt

echo "Installing RunPod Serverless dependencies"
pip3 install huggingface_hub runpod

echo "Downloading Wan 2.1 vae"
cd /workspace/ComfyUI/models/vae
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors

echo "Downloading Wan 2.1 clip_vision"
cd /workspace/ComfyUI/models/clip_vision
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors

echo "Downloading Wan 2.1 diffusion models"
cd /workspace/ComfyUI/models/diffusion_models
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp16.safetensors

echo "Downloading Wan 2.1 text_encoders"
cd /workspace/ComfyUI/models/text_encoders
wget https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors

echo "Creating log directory"
mkdir -p /workspace/logs
