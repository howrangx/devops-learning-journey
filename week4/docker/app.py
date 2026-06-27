#!/usr/bin/env python3

"""
Simple DevOps status app.
Prints system info and environment details when run inside a container.
"""

import os
import platform
import socket
from datetime import datetime


def main():
    print("=" * 44)
    print("  DEVOPS CONTAINER STATUS")
    print("=" * 44)
    print(f"  Timestamp:   {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"  Hostname:    {socket.gethostname()}")
    print(f"  Platform:    {platform.system()} {platform.release()}")
    print(f"  Python:      {platform.python_version()}")
    print(f"  Environment: {os.getenv('APP_ENV', 'not set')}")
    print(f"  Version:     {os.getenv('APP_VERSION', 'not set')}")
    print("=" * 44)
    print()
    print("  Container is running successfully.")
    print()


if __name__ == "__main__":
    main()
