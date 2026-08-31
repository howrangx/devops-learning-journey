# Week 3: Python for DevOps

## Overview

Python as an automation tool rather than a general programming course. The
week covers the standard library pieces that matter for operations work -
subprocess, pathlib, json, logging - plus HTTP and packaging, and ends with
a multi-command CLI tool that gets containerized in Week 4.

## Learning Objectives

- Write Python scripts with proper error handling and structure
- Run and manage system commands from Python
- Work with files, paths and permissions programmatically
- Call REST APIs and parse JSON and YAML
- Manage dependencies with pip and virtual environments
- Build a production-shaped command line tool

## Daily Structure

- Day 1: Python basics and environment setup
- Day 2: Python for system administration
- Day 3: APIs and data formats
- Day 4: Libraries and packages
- Day 5: Practical automation scripts
- Weekend capstone: Python DevOps toolkit

## Deliverables

Documentation

- `notes/day1-python-basics.md`
- `notes/day2-python-sysadmin.md`
- `notes/day3-python-apis.md`
- `notes/day4-python-libraries.md`
- `notes/day5-python-automation.md`
- `CAPSTONE-PROJECT.md` - toolkit design and usage guide

Scripts

- `scripts/devops_toolkit.py` - the capstone. A multi-command CLI built
  with argparse, logging, subprocess and requests, exposing health, logs,
  ping and report subcommands
- `scripts/system_health.py` - system health reporting
- `scripts/config_loader.py` - YAML configuration handling
- `scripts/library_demo.py` - third-party library exercises

Configuration

- `configs/app-config.yml`
- `requirements.txt`

## Technologies

Python 3, pip, venv, argparse, logging, subprocess, pathlib, json,
requests, pyyaml

## Time Commitment

Study 10-12 hours, hands-on 10-12 hours, capstone 2-3 hours.
Total 22-27 hours.

## Notes

Python 3.11 and later enforce PEP 668, so system-wide pip installs are
refused. Use a virtual environment created outside the repository, and keep
`venv/` in `.gitignore`.

## Status

COMPLETE - finished June 20, 2026

Previous: Week 2 - Networking and Git
Next: Week 4 - Docker Fundamentals
