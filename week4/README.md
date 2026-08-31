# Week 4: Docker Fundamentals

## Overview

Containerization from first principles: what a container actually is, how
images are layered, and how to write a Dockerfile that is small and
reproducible. The capstone containerizes the Week 3 toolkit, which is the
first point in this program where two weeks of work combine.

## Learning Objectives

- Explain how containers differ from virtual machines
- Use the core Docker commands confidently
- Write Dockerfiles and understand image layering and caching
- Orchestrate multi-container applications with Docker Compose
- Configure container networking and persistent volumes
- Containerize an existing Python application

## Daily Structure

- Day 1: Container concepts and Docker basics
- Day 2: Docker images and containers
- Day 3: Dockerfiles
- Day 4: Docker Compose
- Day 5: Docker networking and volumes
- Weekend capstone: Containerize the DevOps toolkit

## Deliverables

Documentation

- `notes/day1-docker-basics.md`
- `notes/day2-docker-images.md`
- `notes/day3-dockerfiles.md`
- `notes/day4-docker-compose.md`
- `notes/day5-docker-networking-volumes.md`
- `CAPSTONE-PROJECT.md` - containerization design and usage guide

Container assets

- `docker/Dockerfile.toolkit` - image for the Week 3 DevOps toolkit
- `docker/docker-compose.toolkit.yml` - toolkit stack
- `docker/Dockerfile` - status application image
- `docker/docker-compose.yml` - nginx and application stack
- `docker/app.py` - containerized status application
- `docker/html/index.html` - served content
- `docker/sample.log` - fixture for log parsing exercises

## Technologies

Docker 29.1.3, docker-compose-v2 2.40.3, Dockerfiles, Docker Hub,
bridge networking, named volumes

## Time Commitment

Study 10-12 hours, hands-on 10-12 hours, capstone 2-3 hours.
Total 22-27 hours.

## Notes

The `python:3.11-slim` base image does not include procps, so `uptime` and
`free` are unavailable. Add `apt-get install procps` to any Dockerfile that
needs them.

## Status

COMPLETE - finished June 30, 2026

Previous: Week 3 - Python for DevOps
Next: Week 5 - AWS Fundamentals Part 1
