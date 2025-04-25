FROM runpod/pytorch:2.8.0-py3.11-cuda12.8.1-cudnn-devel-ubuntu22.04

WORKDIR /

# Upgrade apt packages and install required dependencies
RUN apt update && \
    apt upgrade -y && \
    apt install -y \
        git \
        wget \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        build-essential \
        curl \
        ffmpeg && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean -y

# Install Worker dependencies
RUN pip install requests runpod==1.7.9

# Add RunPod Handler and Docker container start script
COPY start.sh rp_handler.py ./

# Add validation schemas
COPY schemas /schemas

# Add workflows
COPY workflows /workflows

# Start the container
RUN chmod +x /start.sh
ENTRYPOINT /start.sh
