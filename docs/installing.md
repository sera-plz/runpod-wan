# Install ComfyUI with Models Encapsulated in Docker Image

This setup encapsulates all models and dependencies within the Docker image, eliminating the need for network volumes.

1. [Create a RunPod Account](https://runpod.io).
2. Create a Secure Cloud [GPU pod](https://www.runpod.io/console/gpu-secure-cloud).
3. Select a GPU instance with sufficient VRAM (recommended: A100 or similar with 40GB+ VRAM).
4. Use the custom Docker image built from this repository.
5. Deploy the GPU Cloud pod.
6. The container will start automatically with all models and ComfyUI pre-installed.

## Building the Docker Image

The Docker image is automatically built using GitHub Actions and published to GitHub Container Registry. The build process includes downloading all models and dependencies.

### Automatic Build Process

- **Trigger**: Builds automatically on pushes to `main`/`master` branches and pull requests
- **Registry**: Published to `ghcr.io/your-username/runpod-wan`
- **Tags**: Includes branch names, commit SHAs, and `latest` for the default branch

### Manual Build (if needed)

If you need to build locally:

1. Clone this repository:
```bash
git clone https://github.com/your-repo/runpod-wan.git
cd runpod-wan
```

2. Build the Docker image:
```bash
docker build -t runpod-wan-comfyui .
```

3. Run the container (for testing):
```bash
docker run --gpus all -p 3000:3000 runpod-wan-comfyui
```

### Using Pre-built Images

Pull the latest image from GitHub Container Registry:
```bash
docker pull ghcr.io/your-username/runpod-wan:latest
```

## RunPod Deployment

1. In your RunPod account, create a new Secure Cloud GPU pod
2. Select a GPU instance with sufficient VRAM (recommended: A100 or similar with 40GB+ VRAM)
3. In the "Container" section, enter:
   - **Container Image**: `ghcr.io/your-username/runpod-wan:latest`
   - **Container Disk**: At least 50GB (models take significant space)
4. Configure any environment variables if needed (optional)
5. Deploy the pod

The container will automatically start ComfyUI with all models loaded and ready to use. No additional setup is required.

## Pre-installed Components

The Docker image includes:

- **ComfyUI** with all required dependencies
- **WAN2.2 Models** (I2V and T2V variants in Q5_K_M GGUF format)
- **Text Encoders** (UMT5-XXL in both GGUF Q8_0 and FP8 formats)
- **CLIP Vision Model** for image processing
- **VAE Model** for latent space operations
- **Custom Nodes**:
  - ComfyUI-Manager
  - KJNodes
  - TeaCache
- **SageAttention** for optimized attention mechanisms
- **Serverless dependencies** (RunPod, ONNX Runtime, Triton, etc.)

## Model Storage

All models are stored in the following directories within the container:
- `/comfywan/models/diffusion_models/` - WAN2.2 diffusion models
- `/comfywan/models/text_encoders/` - Text encoding models
- `/comfywan/models/clip_vision/` - CLIP vision models
- `/comfywan/models/vae/` - VAE models
- `/comfywan/logs/` - Application logs

## Usage

Once deployed on RunPod, the container will automatically start ComfyUI on port 3000 and the RunPod handler. No additional setup is required.