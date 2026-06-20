DAY 5: PRACTICAL AUTOMATION SCRIPTS
Command Reference and Learning Notes

LEARNING DATE: June 20, 2026
COMPLETED BY: Iman

========================================
1. WHAT MAKES A SCRIPT PRODUCTION-READY
========================================

A production-ready automation script has:
- Clear entry point and argument parsing
- Proper logging (not just print statements)
- Configuration from file, not hardcoded
- Error handling at every step
- Clean output and reporting
- Exit codes for success and failure
- Documentation and docstrings

Difference from learning scripts:
Learning script:
- Hardcoded values
- print() everywhere
- No error handling
- Single purpose

Production script:
- Config-driven
- logging module
- Try/except throughout
- Reusable functions
- CLI arguments
- Exit codes

========================================
2. ARGPARSE - COMMAND LINE ARGUMENTS
========================================

Why argparse?
- Accept arguments from terminal
- Built-in help text
- Type validation
- Default values

Basic usage:
import argparse

parser = argparse.ArgumentParser(description='My script')
parser.add_argument('--config', default='config.yml', help='Config file path')
parser.add_argument('--output', default='report.json', help='Output file')
parser.add_argument('--verbose', action='store_true', help='Verbose output')
args = parser.parse_args()

print(args.config)
print(args.verbose)

Run with:
python3 script.py --config app.yml --verbose

Get help:
python3 script.py --help

Positional arguments:
parser.add_argument('filename', help='File to process')

Required arguments:
parser.add_argument('--host', required=True, help='Server host')

========================================
3. LOGGING MODULE
========================================

Why logging over print?
- Log levels (DEBUG, INFO, WARNING, ERROR)
- Write to file and console simultaneously
- Timestamps automatically
- Easy to disable in production
- Standard Python practice

Basic setup:
import logging

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)

Log levels:
logger.debug('Detailed diagnostic info')
logger.info('General info - script started')
logger.warning('Something unexpected happened')
logger.error('Something failed')
logger.critical('Script cannot continue')

Log to file and console:
logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

file_handler = logging.FileHandler('script.log')
console_handler = logging.StreamHandler()

formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)

logger.addHandler(file_handler)
logger.addHandler(console_handler)

========================================
4. SUBPROCESS FOR SYSTEM COMMANDS
========================================

Run command and capture output:
import subprocess

def run_command(command):
    result = subprocess.run(
        command,
        capture_output=True,
        text=True,
        shell=False
    )
    return result.stdout.strip(), result.returncode

output, code = run_command(['df', '-h'])
print(output)

Check return code:
if result.returncode != 0:
    logger.error(f"Command failed: {result.stderr}")

Parse command output:
result = subprocess.run(['free', '-m'], capture_output=True, text=True)
lines = result.stdout.strip().split('\n')
mem_line = lines[1].split()
total = int(mem_line[1])
used = int(mem_line[2])

========================================
5. GENERATING REPORTS
========================================

JSON report:
import json
from datetime import datetime

def save_json_report(data, output_file):
    report = {
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'data': data
    }
    with open(output_file, 'w') as f:
        json.dump(report, f, indent=2)

Structured output to terminal:
def print_section(title, data):
    width = 40
    print('=' * width)
    print(f' {title}')
    print('=' * width)
    for key, value in data.items():
        print(f'  {key:<20} {value}')
    print()

========================================
6. EXIT CODES
========================================

Why exit codes matter:
- Other scripts can check if yours succeeded
- CI/CD pipelines depend on them
- Standard Linux convention

Usage:
import sys

sys.exit(0)   # Success
sys.exit(1)   # General failure
sys.exit(2)   # Misuse or bad argument

Pattern:
def main():
    try:
        run_checks()
        return 0
    except Exception as e:
        logger.error(f"Fatal error: {e}")
        return 1

if __name__ == '__main__':
    sys.exit(main())

========================================
7. COMBINING EVERYTHING
========================================

A complete automation script structure:

#!/usr/bin/env python3
"""Script description here."""

import argparse
import logging
import json
import subprocess
import sys
import yaml
from pathlib import Path
from datetime import datetime

# --- Logging setup ---
logger = logging.getLogger(__name__)

# --- Config loading ---
def load_config(path): ...

# --- Core functions ---
def collect_data(): ...
def run_checks(config): ...

# --- Reporting ---
def save_report(data, output): ...
def print_summary(data): ...

# --- Entry point ---
def main():
    args = parse_args()
    setup_logging(args.verbose)
    config = load_config(args.config)
    data = run_checks(config)
    save_report(data, args.output)
    return 0

if __name__ == '__main__':
    sys.exit(main())

========================================
8. BEST PRACTICES SUMMARY
========================================

Structure:
- One function per task
- main() ties everything together
- sys.exit(main()) as entry point

Error handling:
- Try/except around every external call
- Log errors with context
- Never let script crash silently

Config:
- All settings in YAML config file
- No hardcoded values in script
- Sensible defaults

Logging:
- Use logger, not print
- Log to both file and console
- DEBUG for details, INFO for progress

Output:
- Clear terminal summary
- Machine-readable JSON report
- Consistent formatting

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- argparse for CLI arguments
- logging module for proper output
- subprocess for system commands
- JSON report generation
- Exit codes
- Production script structure
- Combining all Week 3 concepts

Scripts Created:
- system_health.py: Complete automation tool
  combining subprocess, YAML config, logging,
  API calls, JSON reporting, and argparse

========================================
NEXT STEPS: Weekend Capstone - Python DevOps Toolkit
========================================
