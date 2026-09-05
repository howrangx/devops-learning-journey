DAY 1: CONTAINER CONCEPTS AND DOCKER BASICS
Command Reference and Learning Notes

LEARNING DATE: June 23, 2026
COMPLETED BY: Iman

========================================
1. WHAT ARE CONTAINERS?
========================================

A container is a lightweight, isolated environment
that packages an application with everything it needs
to run: code, runtime, libraries, and config.

Containers vs Virtual Machines:

Virtual Machine:
- Full OS per VM (GBs of disk)
- Slow to start (minutes)
- Heavy resource usage
- Hypervisor required

Container:
- Shares host OS kernel
- Fast to start (seconds)
- Lightweight (MBs)
- Container runtime required

Why containers matter in DevOps:
- Consistent environments (dev = staging = prod)
- Fast deployment
- Easy scaling
- Isolation between services
- Reproducible builds

========================================
2. DOCKER ARCHITECTURE
========================================

Key components:

Docker Daemon (dockerd):
- Background service on the host
- Manages images, containers, volumes
- Listens for Docker API requests

Docker CLI:
- Command line tool (docker)
- Sends commands to the daemon
- The component interacted with directly

Docker Hub:
- Public image registry
- Pre-built images (ubuntu, nginx, python)
- Push and pull images

Image:
- Read-only template for containers
- Built from a Dockerfile
- Stored in layers

Container:
- Running instance of an image
- Has its own filesystem, network, processes
- Isolated from host and other containers

Volume:
- Persistent data storage
- Survives container restarts
- Shared between containers

Network:
- Virtual network for containers
- Containers communicate via networks
- Isolated from host by default

Flow:
Dockerfile -> docker build -> Image -> docker run -> Container

========================================
3. INSTALLING AND VERIFYING DOCKER
========================================

Install (Ubuntu/Debian):
sudo apt install docker.io -y

Verify installation:
docker --version

Expected output:
Docker version 29.x.x

Check daemon is running:
sudo systemctl status docker

Start daemon if stopped:
sudo systemctl start docker

Enable on boot:
sudo systemctl enable docker

Run without sudo (add user to docker group):
sudo usermod -aG docker $USER
newgrp docker

Verify with hello-world:
docker run hello-world

========================================
4. CORE DOCKER COMMANDS
========================================

Images

Pull an image from Docker Hub:
docker pull ubuntu
docker pull ubuntu:22.04
docker pull python:3.11-slim

List local images:
docker images
docker image ls

Remove an image:
docker rmi ubuntu
docker rmi image_id

Remove all unused images:
docker image prune

Inspect an image:
docker inspect ubuntu

Search Docker Hub:
docker search nginx

Containers

Run a container:
docker run ubuntu
docker run -it ubuntu bash        (interactive terminal)
docker run -d nginx               (detached/background)
docker run --name myapp nginx     (named container)

List running containers:
docker ps

List all containers (including stopped):
docker ps -a

Stop a container:
docker stop container_id
docker stop myapp

Start a stopped container:
docker start myapp

Remove a container:
docker rm container_id
docker rm myapp

Remove all stopped containers:
docker container prune

Execute command in running container:
docker exec -it myapp bash

View container logs:
docker logs myapp
docker logs -f myapp              (follow/tail)

Inspect a container:
docker inspect myapp

========================================
5. RUNNING THE FIRST CONTAINERS
========================================

Hello World:
docker run hello-world

Interactive Ubuntu shell:
docker run -it ubuntu bash
(type exit to leave)

Run nginx web server:
docker run -d -p 8080:80 --name webserver nginx

Test nginx:
curl http://localhost:8080

Run Python:
docker run -it python:3.11-slim python3

Run a one-off command:
docker run ubuntu echo "Hello from container"

Port mapping explanation:
-p HOST_PORT:CONTAINER_PORT
-p 8080:80 maps host port 8080 to container port 80

========================================
6. CONTAINER LIFECYCLE
========================================

States:
created   - Container created but not started
running   - Container is running
paused    - Container processes paused
stopped   - Container has exited
removed   - Container deleted

Lifecycle commands:
docker create ubuntu          Create without starting
docker start container_id     Start created/stopped container
docker pause container_id     Pause running container
docker unpause container_id   Resume paused container
docker stop container_id      Stop gracefully (SIGTERM)
docker kill container_id      Stop immediately (SIGKILL)
docker rm container_id        Remove stopped container

Common flags for docker run:
-d            Detached (background)
-it           Interactive terminal
--name        Assign a name
-p            Port mapping
-v            Volume mount
-e            Environment variable
--rm          Auto remove when stopped
--network     Connect to network

========================================
7. DOCKER SYSTEM COMMANDS
========================================

System info:
docker info
docker version

Disk usage:
docker system df

Clean up everything unused:
docker system prune

Clean up including volumes:
docker system prune --volumes

View resource usage:
docker stats
docker stats --no-stream       (snapshot, not live)

========================================
8. HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Container vs VM concepts
- Docker architecture
- Docker installation and verification
- Core image commands
- Core container commands
- Container lifecycle
- Port mapping
- System management

Commands Practiced:
- docker pull, docker images, docker rmi
- docker run, docker ps, docker stop
- docker exec, docker logs, docker inspect
- docker system df, docker system prune

========================================
NEXT STEPS: Day 2 - Docker Images and Containers
========================================
