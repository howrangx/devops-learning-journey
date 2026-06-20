#!/usr/bin/env python3

"""
Configuration Loader
Loads and validates YAML configuration files for DevOps automation.
"""

import yaml
import sys
from pathlib import Path


class ConfigLoader:
    def __init__(self, config_file):
        self.config_path = Path(config_file)
        self.config = {}

    def load(self):
        if not self.config_path.exists():
            raise FileNotFoundError(f"Config file not found: {self.config_path}")

        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)

        print(f"Loaded config: {self.config_path}")
        return self.config

    def get(self, section, key=None, default=None):
        if key is None:
            return self.config.get(section, default)
        return self.config.get(section, {}).get(key, default)

    def validate(self, required_sections):
        missing = [s for s in required_sections if s not in self.config]
        if missing:
            raise ValueError(f"Missing required sections: {missing}")
        print("Config validation passed")
        return True

    def display(self):
        print("\n--- Configuration Summary ---")
        for section, values in self.config.items():
            print(f"\n[{section}]")
            if isinstance(values, dict):
                for key, value in values.items():
                    print(f"  {key}: {value}")
            else:
                print(f"  {values}")
        print("-----------------------------\n")


if __name__ == "__main__":
    config_file = sys.argv[1] if len(sys.argv) > 1 else "configs/app-config.yml"

    loader = ConfigLoader(config_file)

    try:
        loader.load()
        loader.validate(['server', 'database', 'monitoring'])
        loader.display()

        print(f"Server host:       {loader.get('server', 'host')}")
        print(f"Server port:       {loader.get('server', 'port')}")
        print(f"Database name:     {loader.get('database', 'name')}")
        print(f"CPU threshold:     {loader.get('monitoring', 'threshold_cpu')}%")
        print(f"Memory threshold:  {loader.get('monitoring', 'threshold_memory')}%")

    except (FileNotFoundError, ValueError) as e:
        print(f"Error: {e}")
        sys.exit(1)
