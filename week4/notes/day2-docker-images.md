DAY 2: DOCKER IMAGES AND CONTAINERS
Command Reference and Learning Notes

LEARNING DATE: June 23, 2026
COMPLETED BY: Iman

========================================
1. DOCKER IMAGES IN DEPTH
========================================

What is an image?
- Read-only template used to create containers
- Built from a series of layers
- Each layer represents a change to the filesystem
- Layers are cached and reused across images

Image naming format:
repository/name:tag

Examples:
ubuntu:22.04
python:3.11-slim
nginx:latest
myusername/myapp:1.0.0

If no tag is specified, Docker uses latest.
Always pin a specific tag in production.

Image layers:
- Each instruction in a Dockerfile creates a layer
- Layers are stacked on top of each other
- Lower layers are shared between images
- Only the top layer is writable (inside a container)

Example layer stack:
Layer 4: Your application code
Layer 3: Python packages (pip install)
Layer 2: Python 3.11 runtime
Layer 1: Ubuntu 22.04 base OS

Benefits of layers:
- Shared layers save disk space
- Cached layers speed up builds
- Only changed layers are rebuilt

========================================
2. IMAGE COMMANDS IN DEPTH
========================================

Pull image:
docker pull python:3.11-slim
docker pull ubuntu:22.04

Pull specific digest (exact version):
docker pull ubuntu@sha256:abc123...

List images:
docker images
docker image ls

Filter images:
docker images ubuntu
docker images --filter "dangling=true"

Inspect image details:
docker inspect ubuntu:22.04
docker inspect --format='{{.Os}}' ubuntu:22.04

View image history (layers):
docker history ubuntu:22.04
docker history --no-trunc ubuntu:22.04

Tag an image:
docker tag ubuntu:22.04 myubuntu:custom
docker tag myapp:latest myusername/myapp:1.0.0

Remove image:
docker rmi ubuntu:22.04
docker rmi image_id

Remove all dangling images:
docker image prune

Remove all unused images:
docker image prune -a

Save image to file:
docker save ubuntu:22.04 -o ubuntu.tar

Load image from file:
docker load -i ubuntu.tar

========================================
3. RUNNING CONTAINERS IN DEPTH
========================================

Basic run:
docker run ubuntu:22.04

Common run flags:
-d              Detached (background)
-it             Interactive terminal
--name          Assign name
-p HOST:CONT    Port mapping
-v HOST:CONT    Volume mount
-e KEY=VALUE    Environment variable
--rm            Remove when stopped
--network       Connect to network
--restart       Restart policy

Environment variables:
docker run -e DB_HOST=localhost -e DB_PORT=5432 myapp

Restart policies:
--restart no            Never restart (default)
--restart always        Always restart
--restart on-failure    Restart only on failure
--restart unless-stopped Restart unless manually stopped

Resource limits:
docker run --memory="256m" myapp
docker run --cpus="0.5" myapp

Run with volume:
docker run -v /host/path:/container/path ubuntu

Run and auto remove:
docker run --rm ubuntu echo "hello"
(container deleted automatically when done)

========================================
4. CONTAINER MANAGEMENT IN DEPTH
========================================

List containers:
docker ps                       Running only
docker ps -a                    All containers
docker ps -q                    IDs only
docker ps --filter "status=exited"

Start, stop, restart:
docker start container_name
docker stop container_name
docker restart container_name

Pause and unpause:
docker pause container_name
docker unpause container_name

Execute command in running container:
docker exec container_name ls -la
docker exec -it container_name bash
docker exec -it container_name python3

Copy files to/from container:
docker cp file.txt container_name:/path/
docker cp container_name:/path/file.txt ./

View container logs:
docker logs container_name
docker logs -f container_name         (follow)
docker logs --tail 50 container_name  (last 50 lines)
docker logs --since 1h container_name (last 1 hour)

View container resource usage:
docker stats
docker stats container_name
docker stats --no-stream              (snapshot)

Inspect container details:
docker inspect container_name
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_name

Rename container:
docker rename old_name new_name

========================================
5. DOCKER HUB
========================================

What is Docker Hub?
- Public registry for Docker images
- Free for public images
- Private repos available (paid)
- Official images maintained by Docker
- Community images from developers

Official images:
ubuntu, debian, alpine
python, node, golang, ruby
nginx, apache, redis, postgres, mysql
jenkins, grafana, prometheus

Pull from Docker Hub:
docker pull nginx
docker pull python:3.11-slim
docker pull postgres:15

Login to Docker Hub:
docker login
(enter username and password)

Push image to Docker Hub:
docker tag myapp:latest username/myapp:latest
docker push username/myapp:latest

Logout:
docker logout

Image naming for Docker Hub:
username/repository:tag
howrangx/devops-toolkit:1.0.0

========================================
6. COMMON BASE IMAGES
========================================

ubuntu:22.04
- Full Ubuntu OS
- Large (120MB+)
- Good for learning
- Many tools available

debian:bookworm-slim
- Minimal Debian OS
- Smaller than Ubuntu
- Good for production

alpine:3.18
- Minimal Linux (5MB)
- Very small images
- Uses musl libc
- Less compatibility

python:3.11-slim
- Python on debian-slim
- Good for Python apps
- Smaller than python:3.11

python:3.11-alpine
- Python on alpine
- Smallest Python image
- May have compatibility issues

Choosing a base image:
- Development: ubuntu or debian
- Production Python: python:3.11-slim
- Smallest possible: alpine
- Always use specific tags, not latest

========================================
7. CONTAINER NETWORKING BASICS
========================================

Default networks:
bridge      Default network for containers
host        Container shares host network
none        No networking

List networks:
docker network ls

Inspect network:
docker network inspect bridge

Container IP address:
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_name

Containers on same network can communicate
by container name as hostname.

Connect container to network:
docker network connect my_network container_name

Port mapping:
-p 8080:80          host_port:container_port
-p 127.0.0.1:8080:80  bind to specific host IP

========================================
8. HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Image layers and caching
- Image commands (pull, inspect, history, tag)
- Container run flags in depth
- Environment variables
- Restart policies
- Resource limits
- Container management (exec, logs, cp, stats)
- Docker Hub (login, push, pull)
- Base image selection
- Container networking basics

Commands Practiced:
- docker history, docker inspect
- docker run with various flags
- docker exec, docker logs, docker stats
- docker cp
- docker tag, docker push
- docker network ls

========================================
NEXT STEPS: Day 3 - Dockerfiles
========================================
