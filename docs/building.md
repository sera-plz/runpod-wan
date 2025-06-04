## Building and setting up serverless endpoints

Just for keeping notes on how to build and deploy

Building docker image:
```bash
# Build the docker image
docker build -t atumn/runpod-wan:${tag} .
# or add --platform linux/amd64 on macOS
docker build --platform linux/amd64 --tag atumn/runpod-wan:${tag} .

# to push image
docker push atumn/runpod-wan:${tag}
```
