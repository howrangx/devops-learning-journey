WEEK 3 CAPSTONE: PYTHON DEVOPS TOOLKIT
Python Automation Tool for System Operations

========================================
OVERVIEW
========================================

A multi-command CLI toolkit for system monitoring, log analysis,
and connectivity checking. Built with Python using subprocess,
requests, pyyaml, argparse, and logging.

========================================
COMMANDS
========================================

health   - Check CPU, memory, and disk usage
logs     - Analyze a log file for errors and warnings
ping     - Check connectivity to configured URLs
report   - Run all checks and save a full JSON report

========================================
USAGE
========================================

System health check:
python3 scripts/devops_toolkit.py health

Analyze a log file:
python3 scripts/devops_toolkit.py logs logs/sample.log

Connectivity check:
python3 scripts/devops_toolkit.py ping

Full report (all checks combined):
python3 scripts/devops_toolkit.py report

Custom config file:
python3 scripts/devops_toolkit.py --config configs/app-config.yml report

Verbose logging:
python3 scripts/devops_toolkit.py --verbose health

========================================
SETUP
========================================

Create virtual environment:
python3 -m venv venv
source venv/bin/activate

Install dependencies:
pip install -r requirements.txt

========================================
CONFIGURATION
========================================

Edit configs/app-config.yml to set:
- Monitoring thresholds (CPU, memory, disk)
- Connectivity targets (URLs to check)
- Server and database info

========================================
OUTPUT
========================================

Terminal:
- Formatted summary for each command
- Timestamped log lines

Files:
- logs/toolkit.log       Running log of all actions
- logs/full_report.json  JSON report from report command

========================================
CONCEPTS USED
========================================

- argparse: CLI subcommands and arguments
- logging: File and console logging
- subprocess: System commands (uptime, free, df)
- requests: HTTP connectivity checks
- pyyaml: YAML configuration loading
- json: Structured report output
- pathlib: File and directory operations
- collections.Counter: Log level counting

========================================
SCRIPTS IN THIS PROJECT
========================================

scripts/devops_toolkit.py  - Main CLI toolkit (capstone)
scripts/system_health.py   - Standalone health monitor (Day 5)
scripts/config_loader.py   - YAML config loader (Day 4)
scripts/library_demo.py    - Library usage demo (Day 4)

========================================
STATUS
========================================

Completed: June 20, 2026
Week: 3 of 16
Phase: Foundations (Weeks 1-4)
