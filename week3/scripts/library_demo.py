#!/usr/bin/env python3

"""
Library Demo
Demonstrates practical use of requests and pyyaml
for common DevOps tasks such as API calls and config handling.
"""

import requests
import yaml
import json
import sys
from pathlib import Path
from datetime import datetime


def fetch_public_ip():
    """Fetch the public IP address of the current machine."""
    print("--- Public IP Lookup ---")
    try:
        response = requests.get("https://api.ipify.org?format=json", timeout=5)
        response.raise_for_status()
        data = response.json()
        print(f"Public IP: {data['ip']}")
        return data['ip']
    except requests.exceptions.RequestException as e:
        print(f"Error fetching IP: {e}")
        return None


def fetch_github_user(username):
    """Fetch basic info about a GitHub user."""
    print(f"\n--- GitHub User: {username} ---")
    try:
        url = f"https://api.github.com/users/{username}"
        response = requests.get(url, timeout=5)
        response.raise_for_status()
        user = response.json()
        print(f"Name:         {user.get('name', 'N/A')}")
        print(f"Public repos: {user.get('public_repos', 0)}")
        print(f"Followers:    {user.get('followers', 0)}")
        print(f"Location:     {user.get('location', 'N/A')}")
        return user
    except requests.exceptions.HTTPError:
        print(f"User '{username}' not found")
        return None
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")
        return None


def load_yaml_config(config_file):
    """Load and display a YAML config file."""
    print(f"\n--- Loading YAML Config: {config_file} ---")
    path = Path(config_file)
    if not path.exists():
        print(f"Config file not found: {config_file}")
        return None

    with open(path, 'r') as f:
        config = yaml.safe_load(f)

    print(f"Sections found: {list(config.keys())}")
    return config


def save_report(ip, github_user, config):
    """Save a summary report as JSON."""
    print("\n--- Saving Report ---")
    report = {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "public_ip": ip,
        "github_user": github_user.get('login') if github_user else None,
        "config_sections": list(config.keys()) if config else []
    }

    report_path = Path("logs/library_demo_report.json")
    report_path.parent.mkdir(exist_ok=True)

    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)

    print(f"Report saved to: {report_path}")
    return report_path


if __name__ == "__main__":
    username = sys.argv[1] if len(sys.argv) > 1 else "torvalds"

    ip = fetch_public_ip()
    user = fetch_github_user(username)
    config = load_yaml_config("configs/app-config.yml")
    save_report(ip, user, config)

    print("\nLibrary demo complete.")
