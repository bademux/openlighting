# Multiarch OpenLightingArchitecture (DMX) docker

# HowTo

To run on host 
```bash
docker run -it -v "$(pwd)/configs":/home/olad/.ola/ --net host bademux/openlighting:latest
```

Build
```bash
docker buildx create --use
# docker run --privileged --rm tonistiigi/binfmt --install all #uncomment if you want to build for arch that is not native for you system
docker buildx build --platform=linux/amd64 --tag bademux/openlighting:latest . --load
```

# Ref
- git repo https://github.com/bademux/openlighting
- docker repo https://hub.docker.com/r/bademux/openlighting
- OpenLightingProject https://github.com/OpenLightingProject/ola

