WEEK 4 CAPSTONE: CONTAINERIZED DEVOPS TOOLKIT
Docker packaging of the Week 3 Python automation tool

========================================
OVERVIEW
========================================

Containerizes the Week 3 devops_toolkit.py using Docker.
The toolkit runs inside a Python 3.11-slim container with
all dependencies and config included in the image.

========================================
FILES
========================================

week4/docker/Dockerfile.toolkit       - Dockerfile for the toolkit
week4/docker/docker-compose.toolkit.yml - Compose definition
week4/docker/sample.log               - Sample log for analysis

========================================
USAGE
========================================

Build the image:
docker build -f week4/docker/Dockerfile.toolkit -t devops-toolkit:1.0 .

Run full report (default):
docker run --rm devops-toolkit:1.0

Run specific command:
docker run --rm devops-toolkit:1.0 python3 devops_toolkit.py health
docker run --rm devops-toolkit:1.0 python3 devops_toolkit.py ping
docker run --rm devops-toolkit:1.0 python3 devops_toolkit.py logs logs/sample.log

Using Docker Compose:
docker compose -f week4/docker/docker-compose.toolkit.yml run toolkit

========================================
WHAT THE CONTAINER RUNS
========================================

health    - CPU load, memory usage, disk usage
logs      - Analyzes sample.log for errors and warnings
ping      - Checks connectivity to GitHub and PyPI
report    - Runs all three and saves full_report.json

========================================
DOCKERFILE EXPLAINED
========================================

Base image: python:3.11-slim
- procps installed for uptime and free commands
- Requirements installed before code (layer caching)
- Config and log file included in image
- Default CMD runs report command

========================================
KEY LESSONS FROM CONTAINERIZING
========================================

- Slim base images do not include system tools by default
  procps was needed for uptime and free
- Layer order matters for caching efficiency
  requirements.txt copied and installed before source code
- Container environment differs from host
  paths must be relative to WORKDIR inside container

========================================
STATUS
========================================

Completed: July 2, 2026
Week: 4 of 16
Phase: Foundations (Weeks 1-4)
