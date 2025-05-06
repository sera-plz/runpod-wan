# Install ComfyUI on your Network Volume

1. [Create a RunPod Account](https://runpod.io).
2. Create a [RunPod Network Volume](https://www.runpod.io/console/user/storage).
3. Attach the Network Volume to a Secure Cloud [GPU pod](https://www.runpod.io/console/gpu-secure-cloud).
4. Select the RunPod Pytorch 2 template.
5. Deploy the GPU Cloud pod.
6. Once the pod is up, open a Terminal and install the required
   dependencies. This can either be done by using the installation
   script, or manually.

## Automatic Installation Script

You can run this automatic installation script which will
automatically install all of the dependencies that get installed
manually below, and then you don't need to follow any of the
manual instructions.

```bash
wget https://raw.githubusercontent.com/ashleykleynhans/runpod-worker-comfyui/main/scripts/install.sh
chmod +x install.sh
./install.sh
```

## Manual Installation

You only need to complete the steps below if you did not run the
automatic installation script above.

1. Install the ComfyUI:
```bash
# Clone the repo
cd /workspace
git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git

# Upgrade Python
apt update
apt -y upgrade
apt-get install aria2 # for downloading models

# Ensure Python version is 3.10.12
python -V

# Create and activate venv
cd ComfyUI
python -m venv /workspace/venv
source /workspace/venv/bin/activate

# Install Torch 
pip install --no-cache-dir torch==2.6.0+cu124 --index-url https://download.pytorch.org/whl/cu124 --no-deps
pip install --no-cache-dir torchvision==0.21.0+cu124 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124

# Install ComfyUI
pip install -r requirements.txt

# Installing ComfyUI Manager
git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
cd custom_nodes/ComfyUI-Manager
pip install -r requirements.txt

# Installing KJNodes
git clone https://github.com/kijai/ComfyUI-KJNodes.git custom_nodes/ComfyUI-KJNodes
cd custom_nodes/ComfyUI-KJNodes
pip install -r requirements.txt
```
2. Install the Serverless dependencies:
```bash
pip install requests runpod==1.7.9
pip install onnxruntime-gpu
pip install triton

# Install SageAttention after ensuring the correct torch version
wget -O https://github.com/atumn/runpod-wan/raw/refs/heads/main/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl
RUN pip install /tmp/sageattention-2.1.1-cp310-cp310-linux_x86_64.whl
```
3. Download models:
```bash
# Download 720p native models
aria2c -x16 -s16 -d /workspace/ComfyUI/models/diffusion_models -o wan2.1_i2v_720p_14B_fp16.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_i2v_720p_14B_fp16.safetensors

aria2c -x16 -s16 -d /workspace/ComfyUI/models/diffusion_models -o wan2.1_t2v_14B_fp16.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/diffusion_models/wan2.1_t2v_14B_fp16.safetensors

# Download text encoders
aria2c -x16 -s16 -d /workspace/ComfyUI/models/text_encoders -o umt5_xxl_fp16.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp16.safetensors

aria2c -x16 -s16 -d /workspace/ComfyUI/models/text_encoders -o open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/open-clip-xlm-roberta-large-vit-huge-14_visual_fp16.safetensors

# Create CLIP vision directory and download models
aria2c -x16 -s16 -d /workspace/ComfyUI/models/clip_vision -o clip_vision_h.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors

# Download VAE
aria2c -x16 -s16 -d /workspace/ComfyUI/models/vae -o Wan2_1_VAE_bf16.safetensors --continue=true https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors

aria2c -x16 -s16 -d /workspace/ComfyUI/models/vae -o wan_2.1_vae.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors

# Download upscaler
aria2c -x16 -s16 -d /workspace/ComfyUI/models/upscale_models -o 4xLSDIR.pth --continue=true https://github.com/Phhofm/models/raw/main/4xLSDIR/4xLSDIR.pth
```
6. Create logs directory:
```bash
mkdir -p /workspace/logs
```