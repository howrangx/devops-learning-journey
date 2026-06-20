#!/usr/bin/env python3

"""
System Health Monitor
Collects system metrics, checks connectivity, and generates a JSON report.
Combines subprocess, YAML config, requests, logging, and argparse.
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


# ======================================
# LOGGING SETUP
# ======================================

def setup_logging(verbose, log_dir):
    level = logging.DEBUG if verbose else logging.INFO
    log_dir = Path(log_dir)
    log_dir.mkdir(exist_ok=True)

    log_file = log_dir / f"system_health_{datetime.now().strftime('%Y%m%d')}.log"

    logger = logging.getLogger()
    logger.setLevel(level)

    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

    file_handler = logging.FileHandler(log_file)
    file_handler.setFormatter(formatter)

    console_handler = logging.StreamHandler()
    console_handler.setFormatter(formatter)

    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logging.getLogger(__name__)


# ======================================
# CONFIG
# ======================================

def load_config(config_path):
    path = Path(config_path)
    if not path.exists():
        raise FileNotFoundError(f"Config not found: {config_path}")
    with open(path, 'r') as f:
        return yaml.safe_load(f)


# ======================================
# SYSTEM METRICS
# ======================================

def get_cpu_load():
    result = subprocess.run(['uptime'], capture_output=True, text=True)
    raw = result.stdout.strip()
    load = raw.split('load average:')[-1].strip().split(',')[0].strip()
    return {'load_1min': load, 'raw': raw}


def get_memory():
    result = subprocess.run(['free', '-m'], capture_output=True, text=True)
    lines = result.stdout.strip().split('\n')
    parts = lines[1].split()
    total = int(parts[1])
    used = int(parts[2])
    percent = round((used / total) * 100, 1)
    return {'total_mb': total, 'used_mb': used, 'percent': percent}


def get_disk():
    result = subprocess.run(['df', '-h', '/'], capture_output=True, text=True)
    parts = result.stdout.strip().split('\n')[1].split()
    percent = int(parts[4].replace('%', ''))
    return {'total': parts[1], 'used': parts[2], 'available': parts[3], 'percent': percent}


# ======================================
# CONNECTIVITY
# ======================================

def check_connectivity(targets):
    results = []
    for target in targets:
        try:
            response = requests.get(target['url'], timeout=5)
            results.append({
                'name': target['name'],
                'url': target['url'],
                'status': response.status_code,
                'reachable': True
            })
        except requests.exceptions.RequestException:
            results.append({
                'name': target['name'],
                'url': target['url'],
                'status': None,
                'reachable': False
            })
    return results


# ======================================
# HEALTH EVALUATION
# ======================================

def evaluate_health(memory, disk, connectivity, thresholds):
    warnings = []

    if memory['percent'] >= thresholds['threshold_memory']:
        warnings.append(f"Memory usage high: {memory['percent']}%")

    if disk['percent'] >= thresholds['threshold_disk']:
        warnings.append(f"Disk usage high: {disk['percent']}%")

    for target in connectivity:
        if not target['reachable']:
            warnings.append(f"Unreachable: {target['name']} ({target['url']})")

    status = 'HEALTHY' if not warnings else 'DEGRADED'
    return status, warnings


# ======================================
# REPORTING
# ======================================

def save_report(data, output_path):
    path = Path(output_path)
    path.parent.mkdir(exist_ok=True)
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)


def print_summary(data):
    width = 44
    print('=' * width)
    print('  SYSTEM HEALTH REPORT')
    print('=' * width)
    print(f"  Timestamp:  {data['timestamp']}")
    print(f"  Status:     {data['health_status']}")
    print()
    print('  --- Metrics ---')
    print(f"  CPU load:   {data['cpu']['load_1min']}")
    print(f"  Memory:     {data['memory']['used_mb']}MB / {data['memory']['total_mb']}MB ({data['memory']['percent']}%)")
    print(f"  Disk:       {data['disk']['used']} / {data['disk']['total']} ({data['disk']['percent']}%)")
    print()
    print('  --- Connectivity ---')
    for t in data['connectivity']:
        status = 'OK' if t['reachable'] else 'FAIL'
        print(f"  {t['name']:<12} {status}")
    if data['warnings']:
        print()
        print('  --- Warnings ---')
        for w in data['warnings']:
            print(f"  - {w}")
    print('=' * width)


# ======================================
# ARGUMENT PARSING
# ======================================

def parse_args():
    parser = argparse.ArgumentParser(description='System Health Monitor')
    parser.add_argument('--config', default='configs/app-config.yml', help='Config file path')
    parser.add_argument('--output', default='logs/health_report.json', help='Output report path')
    parser.add_argument('--verbose', action='store_true', help='Enable verbose logging')
    return parser.parse_args()


# ======================================
# MAIN
# ======================================

def main():
    args = parse_args()
    logger = setup_logging(args.verbose, 'logs')

    logger.info("System health check started")

    try:
        config = load_config(args.config)
        logger.info(f"Config loaded: {args.config}")
    except FileNotFoundError as e:
        logger.error(e)
        return 1

    thresholds = config.get('monitoring', {})
    connectivity_targets = config.get('connectivity', {}).get('targets', [])

    logger.info("Collecting system metrics")
    cpu = get_cpu_load()
    memory = get_memory()
    disk = get_disk()

    logger.info("Checking connectivity")
    connectivity = check_connectivity(connectivity_targets)

    status, warnings = evaluate_health(memory, disk, connectivity, thresholds)

    report = {
        'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
        'health_status': status,
        'cpu': cpu,
        'memory': memory,
        'disk': disk,
        'connectivity': connectivity,
        'warnings': warnings
    }

    save_report(report, args.output)
    logger.info(f"Report saved: {args.output}")

    print_summary(report)

    if warnings:
        logger.warning(f"{len(warnings)} warning(s) detected")
        return 1

    logger.info("Health check complete - all systems OK")
    return 0


if __name__ == '__main__':
    sys.exit(main())
