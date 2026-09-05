DAY 4: DOCKER COMPOSE
Command Reference and Learning Notes

LEARNING DATE: June 24, 2026
COMPLETED BY: Iman

========================================
1. WHAT IS DOCKER COMPOSE?
========================================

Docker Compose is a tool for defining and running
multi-container applications using a single YAML file.

Without Compose, running a web app with a database
requires multiple docker run commands with the right
flags, networks, and volumes set manually.

With Compose, everything is defined in one file
and started with one command.

Real-world example:
- nginx: reverse proxy on port 80
- app: Python web server on port 8000
- redis: cache on port 6379
- postgres: database on port 5432

All four start with: docker compose up

========================================
2. DOCKER COMPOSE FILE STRUCTURE
========================================

File name: docker-compose.yml

Basic structure:
services:
  service_name:
    image: image_name
    ports:
      - "host:container"
    environment:
      - KEY=VALUE
    volumes:
      - host_path:container_path
    networks:
      - network_name

networks:
  network_name:

volumes:
  volume_name:

A service is one container definition.
There can be as many services as needed.

========================================
3. SERVICE CONFIGURATION
========================================

Use an existing image:
services:
  web:
    image: nginx:latest

Build from Dockerfile:
services:
  app:
    build: .

Build from specific directory:
services:
  app:
    build:
      context: ./app
      dockerfile: Dockerfile

Port mapping:
services:
  web:
    ports:
      - "8080:80"
      - "8443:443"

Environment variables:
services:
  app:
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432

Or from a file:
services:
  app:
    env_file:
      - .env

Volume mounts:
services:
  app:
    volumes:
      - ./data:/app/data
      - myvolume:/var/lib/data

Named volumes:
volumes:
  myvolume:

Restart policy:
services:
  app:
    restart: always
    restart: on-failure
    restart: unless-stopped

Dependencies:
services:
  app:
    depends_on:
      - db
  db:
    image: postgres:15

(app starts after db, but does not wait for db to be ready)

========================================
4. NETWORKING IN COMPOSE
========================================

By default, Compose creates one network for all services.
Services can reach each other by service name as hostname.

Example:
services:
  web:
    image: nginx
  app:
    image: python:3.11-slim

web can reach app at http://app:8000
app can reach web at http://web:80

Custom networks:
services:
  web:
    networks:
      - frontend
  app:
    networks:
      - frontend
      - backend
  db:
    networks:
      - backend

networks:
  frontend:
  backend:

This isolates db from web while app talks to both.

========================================
5. DOCKER COMPOSE COMMANDS
========================================

Start services (foreground):
docker compose up

Start services (background):
docker compose up -d

Start specific service:
docker compose up -d web

Stop services:
docker compose down

Stop and remove volumes:
docker compose down -v

Build images:
docker compose build

Build without cache:
docker compose build --no-cache

View running services:
docker compose ps

View logs:
docker compose logs
docker compose logs web
docker compose logs -f web       (follow)
docker compose logs --tail 50

Execute command in service:
docker compose exec web bash
docker compose exec app python3

Restart a service:
docker compose restart web

Pull latest images:
docker compose pull

View service config:
docker compose config

Scale a service:
docker compose up -d --scale app=3

========================================
6. COMPOSE FILE VERSIONS
========================================

Modern Docker Compose does not require a version key.
Older files may have:
version: '3.8'

This is no longer needed and can be omitted.

========================================
7. VOLUMES IN COMPOSE
========================================

Bind mount (host directory):
volumes:
  - ./html:/usr/share/nginx/html

Named volume (managed by Docker):
services:
  db:
    volumes:
      - pgdata:/var/lib/postgresql/data

volumes:
  pgdata:

Named volumes persist when containers are removed.
Bind mounts reflect live changes on host.

========================================
8. PRACTICAL PATTERNS
========================================

Development pattern:
- Bind mount source code
- Live code reload
- Debug ports exposed

Production pattern:
- Build images
- Named volumes for data
- Restart policies
- No debug ports

Health checks:
services:
  db:
    healthcheck:
      test: ["CMD", "pg_isready"]
      interval: 10s
      timeout: 5s
      retries: 5

  app:
    depends_on:
      db:
        condition: service_healthy

========================================
9. HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Docker Compose concepts
- docker-compose.yml structure
- Service configuration
- Port mapping and environment variables
- Networking between services
- Volumes in Compose
- All Compose commands
- Practical patterns

Files Created:
- week4/docker/docker-compose.yml
- week4/docker/html/index.html

Commands Practiced:
- docker compose up -d
- docker compose ps
- docker compose logs
- docker compose exec
- docker compose down

========================================
NEXT STEPS: Day 5 - Docker Networking and Volumes
========================================
