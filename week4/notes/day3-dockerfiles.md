DAY 3: DOCKERFILES
Command Reference and Learning Notes

LEARNING DATE: June 24, 2026
COMPLETED BY: Iman

========================================
1. WHAT IS A DOCKERFILE?
========================================

A Dockerfile is a plain text file containing
instructions to build a custom Docker image.

Docker reads the file top to bottom, executing
each instruction and creating a new layer.

Build an image from a Dockerfile:
docker build -t myapp:1.0 .

The dot (.) means look for Dockerfile in current directory.

Flow:
Dockerfile -> docker build -> Image -> docker run -> Container

========================================
2. DOCKERFILE INSTRUCTIONS
========================================

FROM
- First instruction in every Dockerfile
- Sets the base image
- All subsequent instructions build on top

FROM ubuntu:22.04
FROM python:3.11-slim
FROM alpine:3.18

RUN
- Executes a command during build
- Creates a new layer
- Used to install packages, create files, etc.

RUN apt-get update && apt-get install -y curl
RUN pip install requests pyyaml
RUN mkdir -p /app/logs

Combine RUN commands to reduce layers:
RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

COPY
- Copies files from host into image
- Source is relative to build context
- Destination is path inside image

COPY app.py /app/
COPY requirements.txt /app/
COPY . /app/

ADD
- Similar to COPY but with extra features
- Can extract tar archives automatically
- Can fetch URLs (not recommended)
- Use COPY unless you need ADD features

ADD archive.tar.gz /app/

WORKDIR
- Sets the working directory for subsequent instructions
- Created automatically if it does not exist
- Like running cd inside the image

WORKDIR /app

ENV
- Sets environment variables inside the image
- Available at build time and runtime

ENV APP_ENV=production
ENV PORT=8080
ENV DB_HOST=localhost

EXPOSE
- Documents which port the container listens on
- Does not actually publish the port
- Informational only - you still need -p when running

EXPOSE 8080

CMD
- Default command to run when container starts
- Only one CMD per Dockerfile (last one wins)
- Can be overridden at docker run

CMD ["python3", "app.py"]
CMD ["nginx", "-g", "daemon off;"]

ENTRYPOINT
- Sets the main executable for the container
- CMD becomes arguments to ENTRYPOINT
- Harder to override than CMD

ENTRYPOINT ["python3"]
CMD ["app.py"]

(runs: python3 app.py)

ARG
- Build-time variable
- Not available at runtime (unlike ENV)
- Can be passed with --build-arg

ARG VERSION=1.0
RUN echo "Building version $VERSION"

Build with:
docker build --build-arg VERSION=2.0 .

USER
- Sets which user runs subsequent instructions
- Good security practice (avoid running as root)

USER nobody
USER 1000

========================================
3. LAYER CACHING
========================================

Docker caches each layer during build.
If a layer has not changed, Docker reuses the cache.
If a layer changes, all subsequent layers are rebuilt.

This means instruction order matters.

Bad order (cache busted often):
COPY . /app/
RUN pip install -r requirements.txt

If any file changes, pip install reruns every time.

Good order (cache efficient):
COPY requirements.txt /app/
RUN pip install -r requirements.txt
COPY . /app/

pip install only reruns if requirements.txt changes.
Code changes only rebuild the last COPY layer.

Rule: Put instructions that change least often at the top.

Force rebuild without cache:
docker build --no-cache -t myapp .

========================================
4. .DOCKERIGNORE
========================================

Works like .gitignore but for Docker builds.
Prevents files from being sent to Docker daemon.

Create .dockerignore in same directory as Dockerfile.

Example .dockerignore:
.git
__pycache__
*.pyc
*.log
logs/
venv/
.env
tests/
*.md
.gitignore

Benefits:
- Faster builds (smaller build context)
- Smaller images
- No sensitive files in image

========================================
5. BUILDING IMAGES
========================================

Basic build:
docker build -t myapp .

Build with tag:
docker build -t myapp:1.0.0 .

Build from different directory:
docker build -t myapp /path/to/context

Build with different Dockerfile name:
docker build -f Dockerfile.prod -t myapp .

Build with build argument:
docker build --build-arg ENV=production -t myapp .

No cache:
docker build --no-cache -t myapp .

View build progress verbosely:
docker build --progress=plain -t myapp .

After building:
docker images
docker run myapp

========================================
6. MULTI-STAGE BUILDS
========================================

Build in one stage, copy result to final image.
Keeps final image small.

Example:
FROM python:3.11 AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --user -r requirements.txt

FROM python:3.11-slim
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
CMD ["python3", "app.py"]

Result: final image only has runtime,
not build tools. Much smaller.

========================================
7. DOCKERFILE BEST PRACTICES
========================================

Use specific tags:
FROM python:3.11-slim   (good)
FROM python:latest      (avoid)

Combine RUN commands:
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

Order layers by change frequency:
FROM, ENV, RUN (installs) -> COPY requirements -> RUN pip install -> COPY code

Use .dockerignore:
Always create one to keep context small

Do not run as root:
USER nobody

Use WORKDIR, not cd:
WORKDIR /app    (good)
RUN cd /app     (avoid)

Clean up in same RUN layer:
RUN apt-get update && \
    apt-get install -y curl && \
    rm -rf /var/lib/apt/lists/*

========================================
8. HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Dockerfile instructions (FROM, RUN, COPY, WORKDIR, ENV, EXPOSE, CMD)
- Layer caching and build order
- .dockerignore file
- Building images with docker build
- Multi-stage builds concept
- Dockerfile best practices

Files Created:
- week4/docker/Dockerfile
- week4/docker/app.py
- week4/docker/.dockerignore

Commands Practiced:
- docker build -t name .
- docker build --no-cache
- docker run custom image
- docker images

========================================
NEXT STEPS: Day 4 - Docker Compose
========================================
