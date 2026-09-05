DAY 5: DOCKER NETWORKING AND VOLUMES
Command Reference and Learning Notes

LEARNING DATE: June 30, 2026
COMPLETED BY: Iman

========================================
1. DOCKER NETWORKING IN DEPTH
========================================

Network drivers:

bridge (default)
- Default network for standalone containers
- Containers get internal IP addresses
- Isolated from host network
- Containers on same bridge can communicate

host
- Container shares host network stack directly
- No port mapping needed
- No network isolation
- Faster but less secure

none
- No networking at all
- Fully isolated container

overlay
- Used in Docker Swarm
- Connects containers across multiple hosts
- Not needed for single-host development

========================================
2. NETWORK COMMANDS
========================================

List networks:
docker network ls

Create a network:
docker network create mynetwork
docker network create --driver bridge mynetwork

Inspect a network:
docker network inspect mynetwork

Remove a network:
docker network rm mynetwork

Remove unused networks:
docker network prune

Connect running container to network:
docker network connect mynetwork container_name

Disconnect container from network:
docker network disconnect mynetwork container_name

Run container on specific network:
docker run --network mynetwork myapp

========================================
3. CONTAINER TO CONTAINER COMMUNICATION
========================================

On the default bridge network, containers
can only reach each other by IP address.

On a custom network, Docker provides automatic
DNS resolution. Containers can reach each other
by container name or Compose service name.

Example:
docker network create appnet
docker run -d --name db --network appnet postgres:15
docker run -d --name app --network appnet myapp

Inside app container:
ping db
curl http://db:5432

This works because Docker's embedded DNS resolves
"db" to the container's internal IP automatically.

In Docker Compose, this works by default since
Compose creates a custom network automatically.

========================================
4. PORT PUBLISHING VS NETWORK COMMUNICATION
========================================

Two separate concepts:

Port publishing (-p):
- Exposes a container port to the HOST machine
- Needed to access the container from outside Docker
- Example: -p 8080:80 makes the service reachable at localhost:8080

Network communication (container name):
- Containers on the same network reach each other directly
- No port publishing needed between containers
- Example: app container reaches db on port 5432
  using db:5432, no -p needed for db

Rule of thumb:
- Publish ports only for services that need
  external access (web servers, APIs)
- Internal services (databases, caches) usually
  do not need published ports

========================================
5. DOCKER VOLUMES IN DEPTH
========================================

Why volumes?
- Containers are ephemeral, data is lost on removal
- Volumes persist data outside the container lifecycle
- Volumes can be shared between containers
- Managed by Docker, easier than bind mounts

Types of data storage:

Named volumes
- Created and managed by Docker
- Stored in /var/lib/docker/volumes/
- Best for persistent application data

Bind mounts
- Maps a host directory directly into container
- Good for development (live code reload)
- Host path must exist

tmpfs mounts
- Stored in host memory only
- Never written to disk
- Good for sensitive temporary data

========================================
6. VOLUME COMMANDS
========================================

Create a volume:
docker volume create myvolume

List volumes:
docker volume ls

Inspect a volume:
docker volume inspect myvolume

Remove a volume:
docker volume rm myvolume

Remove unused volumes:
docker volume prune

Run container with named volume:
docker run -v myvolume:/app/data myapp

Run container with bind mount:
docker run -v /host/path:/container/path myapp

Read-only mount:
docker run -v myvolume:/app/data:ro myapp

========================================
7. VOLUMES IN DOCKER COMPOSE
========================================

Named volume:
services:
  db:
    image: postgres:15
    volumes:
      - dbdata:/var/lib/postgresql/data

volumes:
  dbdata:

Bind mount:
services:
  web:
    volumes:
      - ./html:/usr/share/nginx/html

Data in named volumes persists across:
docker compose down
docker compose up

Data in named volumes is removed only with:
docker compose down -v

========================================
8. INSPECTING CONTAINER NETWORK DETAILS
========================================

Get container IP address:
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_name

List all networks a container is on:
docker inspect --format='{{range $net,$conf := .NetworkSettings.Networks}}{{$net}} {{end}}' container_name

Test connectivity between containers:
docker exec container1 ping container2
docker exec container1 curl http://container2:port

========================================
9. PRACTICAL PATTERNS
========================================

Pattern: Isolated backend network
- Frontend (web) on public network
- Backend (db) on private network only
- App container bridges both networks

Pattern: Persistent database with Compose
services:
  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
    volumes:
      - dbdata:/var/lib/postgresql/data

volumes:
  dbdata:

Data survives container recreation since the
volume is independent of the container lifecycle.

Pattern: Development bind mount for live reload
services:
  app:
    build: .
    volumes:
      - ./src:/app/src

Code changes on host reflect immediately
inside the running container.

========================================
10. HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Network drivers (bridge, host, none)
- Custom networks and DNS resolution
- Container to container communication
- Port publishing vs internal networking
- Named volumes vs bind mounts vs tmpfs
- Volume commands
- Volumes in Docker Compose
- Inspecting network and container details

Commands Practiced:
- docker network create, inspect, rm
- docker volume create, inspect, rm
- docker exec for connectivity testing
- docker inspect for IP and network details

========================================
NEXT STEPS: Weekend Capstone - Containerize the DevOps Toolkit
========================================
