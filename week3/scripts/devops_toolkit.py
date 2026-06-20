#!/usr/bin/env python3

"""
DevOps Toolkit
A multi-command automation tool for system health, log analysis,
connectivity checks, and full reporting.

Usage:
  python3 devops_toolkit.py health
  python3 devops_toolkit.py logs <logfile>
  python3 devops_toolkit.py ping
  python3 devops_toolkit.py report
"""

import argparse
import json
import logging
import subprocess
import sys
import yaml
import requests
from datetime import datetime
from pathlib import Path
from collections import Counter


# ======================================
# LOGGING
# ======================================

def setup_logging(verbose):
    level = logging.DEBUG if verbose else logging.INFO
    log_dir = Path('logs')
    log_dir.mkdir(exist_ok=True)

    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

    file_handler = logging.FileHandler(log_dir / 'toolkit.log')
    file_handler.setFormatter(formatter)

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)

    logger = logging.getLogger()
    logger.setLevel(level)
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logging.getLogger(__name__)


# ======================================
# CONFIG
# ======================================

def load_config(config_path='configs/app-config.yml'):
    path = Path(config_path)
    if not path.exists():
        raise FileNotFoundError(f"Config not found: {config_path}")
    with open(path, 'r') as f:
        return yaml.safe_load(f)


# ======================================
# HELPERS
# ======================================

def print_header(title):
    width = 44
    print()
    print('=' * width)
    print(f'  {title}')
    print('=' * width)


def save_report(data, path):
    out = Path(path)
    out.parent.mkdir(exist_ok=True)
    with open(out, 'w') as f:
        json.dump(data, f, indent=2)


# ======================================
# HEALTH COMMAND
# ======================================

def get_cpu_load():
    result = subprocess.run(['uptime'], capture_output=True, text=True)
    load = result.stdout.split('load average:')[-1].strip().split(',')[0].strip()
    return load


def get_memory():
    result = subprocess.run(['free', '-m'], capture_output=True, text=True)
    parts = result.stdout.strip().split('\n')[1].split()
    total, used = int(parts[1]), int(parts[2])
    return {
        'total_mb': total,
        'used_mb': used,
        'percent': round((used / total) * 100, 1)
    }


def get_disk():
    result = subprocess.run(['df', '-h', '/'], capture_output=True, text=True)
    parts = result.stdout.strip().split('\n')[1].split()
    return {
        'total': parts[1],
        'used': parts[2],
        'available': parts[3],
        'percent': int(parts[4].replace('%', ''))
    }


def cmd_health(args, config, logger):
    logger.info("Running health check")
    thresholds = config.get('monitoring', {})

    cpu = get_cpu_load()
    memory = get_memory()
    disk = get_disk()

    warnings = []
    if memory['percent'] >= thresholds.get('threshold_memory', 80):
        warnings.append(f"Memory usage high: {memory['percent']}%")
    if disk['percent'] >= thresholds.get('threshold_disk', 80):
        warnings.append(f"Disk usage high: {disk['percent']}%")

    status = 'HEALTHY' if not warnings else 'DEGRADED'

    print_header('SYSTEM HEALTH')
    print(f"  Status:   {status}")
    print(f"  CPU load: {cpu}")
    print(f"  Memory:   {memory['used_mb']}MB / {memory['total_mb']}MB ({memory['percent']}%)")
    print(f"  Disk:     {disk['used']} / {disk['total']} ({disk['percent']}%)")
    if warnings:
        print()
        for w in warnings:
            print(f"  WARNING: {w}")
    print()

    return {
        'status': status,
        'cpu_load': cpu,
        'memory': memory,
        'disk': disk,
        'warnings': warnings
    }


# ======================================
# LOGS COMMAND
# ======================================

def cmd_logs(args, config, logger):
    log_file = Path(args.file)
    logger.info(f"Analyzing log file: {log_file}")

    if not log_file.exists():
        logger.error(f"Log file not found: {log_file}")
        return None

    with open(log_file, 'r') as f:
        lines = f.readlines()

    total = len(lines)
    levels = Counter()
    errors = []
    warnings = []

    for line in lines:
        line = line.strip()
        if 'ERROR' in line:
            levels['ERROR'] += 1
            errors.append(line)
        elif 'WARNING' in line:
            levels['WARNING'] += 1
            warnings.append(line)
        elif 'INFO' in line:
            levels['INFO'] += 1

    print_header(f'LOG ANALYSIS: {log_file.name}')
    print(f"  Total lines:  {total}")
    print(f"  INFO:         {levels['INFO']}")
    print(f"  WARNING:      {levels['WARNING']}")
    print(f"  ERROR:        {levels['ERROR']}")

    if errors:
        print()
        print('  --- Recent Errors ---')
        for e in errors[-3:]:
            print(f"  {e}")

    if warnings:
        print()
        print('  --- Recent Warnings ---')
        for w in warnings[-3:]:
            print(f"  {w}")
    print()

    return {
        'file': str(log_file),
        'total_lines': total,
        'counts': dict(levels),
        'recent_errors': errors[-3:],
        'recent_warnings': warnings[-3:]
    }


# ======================================
# PING COMMAND
# ======================================

def cmd_ping(args, config, logger):
    targets = config.get('connectivity', {}).get('targets', [])
    logger.info(f"Checking connectivity for {len(targets)} targets")

    results = []
    print_header('CONNECTIVITY CHECK')

    for target in targets:
        try:
            response = requests.get(target['url'], timeout=5)
            reachable = True
            status_code = response.status_code
            elapsed = round(response.elapsed.total_seconds() * 1000)
            print(f"  {target['name']:<12} OK    {status_code}  {elapsed}ms")
        except requests.exceptions.RequestException:
            reachable = False
            status_code = None
            elapsed = None
            print(f"  {target['name']:<12} FAIL")

        results.append({
            'name': target['name'],
            'url': target['url'],
            'reachable': reachable,
            'status_code': status_code,
            'elapsed_ms': elapsed
        })

    print()
    return results


# ======================================
# REPORT COMMAND
# ======================================

def cmd_report(args, config, logger):
    logger.info("Generating full report")

    health = cmd_health(args, config, logger)

    class LogArgs:
        file = 'logs/sample.log'
    logs = cmd_logs(LogArgs(), config, logger)

    ping = cmd_ping(args, config, logger)

    report = {
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'health': health,
        'logs': logs,
        'connectivity': ping
    }

    output = 'logs/full_report.json'
    save_report(report, output)

    print_header('REPORT SUMMARY')
    print(f"  Timestamp:    {report['timestamp']}")
    print(f"  Health:       {health['status']}")
    print(f"  Log errors:   {logs['counts'].get('ERROR', 0)}")
    print(f"  Connectivity: {sum(1 for t in ping if t['reachable'])}/{len(ping)} reachable")
    print(f"  Saved to:     {output}")
    print()

    logger.info(f"Full report saved to {output}")
    return report


# ======================================
# ARGUMENT PARSING
# ======================================

def parse_args():
    parser = argparse.ArgumentParser(
        description='DevOps Toolkit - system health, log analysis, connectivity'
    )
    parser.add_argument('--config', default='configs/app-config.yml')
    parser.add_argument('--verbose', action='store_true')

    subparsers = parser.add_subparsers(dest='command')
    subparsers.required = True

    subparsers.add_parser('health', help='Check system health')

    logs_parser = subparsers.add_parser('logs', help='Analyze a log file')
    logs_parser.add_argument('file', help='Path to log file')

    subparsers.add_parser('ping', help='Check URL connectivity')
    subparsers.add_parser('report', help='Run all checks and save report')

    return parser.parse_args()


# ======================================
# MAIN
# ======================================

def main():
    args = parse_args()
    logger = setup_logging(args.verbose)

    try:
        config = load_config(args.config)
    except FileNotFoundError as e:
        print(f"Error: {e}")
        return 1

    commands = {
        'health': cmd_health,
        'logs': cmd_logs,
        'ping': cmd_ping,
        'report': cmd_report
    }

    result = commands[args.command](args, config, logger)
    return 0 if result else 1


if __name__ == '__main__':
    sys.exit(main())
