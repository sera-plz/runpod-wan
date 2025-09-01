# Use multi-stage build with caching optimizations
FROM nvidia/cuda:12.8.1-devel-ubuntu22.04

# Consolidated environment variables
ENV DEBIAN_FRONTEND=noninteractive \
   PIP_PREFER_BINARY=1 \
   PYTHONUNBUFFERED=1 \
   CMAKE_BUILD_PARALLEL_LEVEL=8

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /

# Install Python 3.10 specifically and make it the default
RUN apt-get update && apt-get install -y --no-install-recommends \
   python3.10 python3.10-dev python3.10-distutils python3-pip python3.10-venv \
   curl ffmpeg ninja-build git git-lfs wget aria2 vim libgl1 libglib2.0-0 build-essential gcc \
   && ln -sf /usr/bin/python3.10 /usr/bin/python \
   && ln -sf /usr/bin/python3.10 /usr/bin/python3 \
   && curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 \
   && ln -sf /usr/local/bin/pip /usr/bin/pip \
   && ln -sf /usr/local/bin/pip /usr/bin/pip3 \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

# Verify Python version
RUN python --version && pip --version

# install runpod and requests for python
RUN pip install runpod requests websocket-client

# Clone and install ComfyUI
RUN cd / && git clone --depth=1 https://github.com/comfyanonymous/ComfyUI.git comfywan

# Create and activate venv for ComfyUI
RUN cd /comfywan && python -m venv /workspace/venv
ENV PATH="/workspace/venv/bin:$PATH"

# Install Torch and ComfyUI dependencies
RUN pip install --no-cache-dir torch==2.7.0+cu128 --index-url https://download.pytorch.org/whl/cu128 --no-deps
RUN pip install --no-cache-dir torchvision==0.22.0+cu128 torchaudio==2.7.0 --index-url https://download.pytorch.org/whl/cu128
RUN cd /comfywan && pip install -r requirements.txt

# Install ComfyUI Manager
RUN cd /comfywan && git clone https://github.com/ltdrdata/ComfyUI-Manager.git custom_nodes/ComfyUI-Manager
RUN cd /comfywan/custom_nodes/ComfyUI-Manager && pip install -r requirements.txt

# Install KJNodes
RUN cd /comfywan && git clone https://github.com/kijai/ComfyUI-KJNodes.git custom_nodes/ComfyUI-KJNodes
RUN cd /comfywan/custom_nodes/ComfyUI-KJNodes && pip install -r requirements.txt

# Install TeaCache
RUN cd /comfywan && git clone https://github.com/welltop-cn/ComfyUI-TeaCache.git custom_nodes/ComfyUI-TeaCache
RUN cd /comfywan/custom_nodes/ComfyUI-TeaCache && pip install -r requirements.txt

# Install additional serverless dependencies
RUN pip install onnxruntime-gpu triton mutagen

# Install SageAttention
RUN git clone https://github.com/thu-ml/SageAttention.git /SageAttention
RUN cd /SageAttention && python setup.py install

# Create model directories
RUN mkdir -p /comfywan/models/diffusion_models /comfywan/models/text_encoders /comfywan/models/clip_vision /comfywan/models/vae /comfywan/logs

# Download WAN2.2 I2V models
RUN aria2c -x16 -s16 -d /comfywan/models/diffusion_models -o wan2.2_i2v_high_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-I2V-A14B-GGUF/resolve/main/wan2.2_i2v_high_noise_14B_Q5_K_M.gguf
RUN aria2c -x16 -s16 -d /comfywan/models/diffusion_models -o wan2.2_i2v_low_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-I2V-A14B-GGUF/resolve/main/wan2.2_i2v_low_noise_14B_Q5_K_M.gguf

# Download WAN2.2 T2V models
RUN aria2c -x16 -s16 -d /comfywan/models/diffusion_models -o wan2.2_t2v_high_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-T2V-A14B-GGUF/resolve/main/wan2.2_t2v_high_noise_14B_Q5_K_M.gguf
RUN aria2c -x16 -s16 -d /comfywan/models/diffusion_models -o wan2.2_t2v_low_noise_14B_Q5_K_M.gguf --continue=true https://huggingface.co/bullerwins/Wan2.2-T2V-A14B-GGUF/resolve/main/wan2.2_t2v_low_noise_14B_Q5_K_M.gguf

# Download text encoders
RUN aria2c -x16 -s16 -d /comfywan/models/text_encoders -o umt5-xxl-encoder-Q8_0.gguf --continue=true https://huggingface.co/city96/umt5-xxl-encoder-gguf/resolve/main/umt5-xxl-encoder-Q8_0.gguf
RUN aria2c -x16 -s16 -d /comfywan/models/text_encoders -o umt5_xxl_fp8_e4m3fn_scaled.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors

# Download CLIP vision model
RUN aria2c -x16 -s16 -d /comfywan/models/clip_vision -o clip_vision_h.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/clip_vision/clip_vision_h.safetensors

# Download VAE
RUN aria2c -x16 -s16 -d /comfywan/models/vae -o wan_2.1_vae.safetensors --continue=true https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors

# Add RunPod Handler and Docker container start script
COPY start.sh rp_handler.py ./

COPY comfy-manager-set-mode.sh /usr/local/bin/comfy-manager-set-mode
RUN chmod +x /usr/local/bin/comfy-manager-set-mode

RUN chmod +x /start.sh
ENTRYPOINT /start.sh