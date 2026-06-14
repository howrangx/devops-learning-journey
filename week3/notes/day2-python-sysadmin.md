DAY 2: PYTHON FOR SYSTEM ADMINISTRATION
Command Reference and Learning Notes

LEARNING DATE: June 14, 2026
COMPLETED BY: Iman

========================================
1. SUBPROCESS MODULE
========================================

What is Subprocess?
- Execute system commands from Python
- Capture output
- Handle errors
- Manage processes

Basic Command Execution

Simple command:
import subprocess

result = subprocess.run(["ls", "-la"], capture_output=True, text=True)
print(result.stdout)
print(result.stderr)
print(result.returncode)

Check success:
if result.returncode == 0:
    print("Command succeeded")
else:
    print("Command failed")

Capture output:
result = subprocess.run(["pwd"], capture_output=True, text=True)
current_dir = result.stdout.strip()
print(f"Current directory: {current_dir}")

Run shell command:
result = subprocess.run("echo 'Hello' | grep Hello", shell=True, capture_output=True, text=True)
print(result.stdout)

Error handling:
try:
    result = subprocess.run(["false"], capture_output=True, text=True, check=True)
except subprocess.CalledProcessError as e:
    print(f"Command failed with code {e.returncode}")

Practical Examples

Get hostname:
result = subprocess.run(["hostname"], capture_output=True, text=True)
hostname = result.stdout.strip()
print(f"Hostname: {hostname}")

Get disk space:
result = subprocess.run(["df", "-h"], capture_output=True, text=True)
disk_info = result.stdout
print(disk_info)

Get memory info:
result = subprocess.run(["free", "-h"], capture_output=True, text=True)
memory_info = result.stdout
print(memory_info)

Check if service running:
result = subprocess.run(["systemctl", "is-active", "nginx"], capture_output=True, text=True)
if "active" in result.stdout:
    print("nginx is running")
else:
    print("nginx is not running")

========================================
2. PATHLIB MODULE
========================================

Why Pathlib?
- Object-oriented path handling
- Cross-platform compatibility
- Cleaner than os.path

Creating Paths

Import:
from pathlib import Path

Create path:
p = Path(".")
home = Path.home()
current = Path.cwd()

Joining paths:
config_file = Path.home() / ".config" / "app.conf"
print(config_file)

Path Checking

Check if exists:
if Path("file.txt").exists():
    print("File exists")

Check if file:
if Path("file.txt").is_file():
    print("It is a file")

Check if directory:
if Path("directory").is_dir():
    print("It is a directory")

Get file size:
size = Path("file.txt").stat().st_size
print(f"Size: {size} bytes")

Path Operations

Get filename:
path = Path("~/config/app.conf")
filename = path.name
print(filename)

Get parent directory:
parent = path.parent
print(parent)

Get file extension:
extension = path.suffix
print(extension)

List files:
p = Path(".")
for file in p.glob("*.py"):
    print(file)

List recursively:
for file in p.glob("**/*.py"):
    print(file)

Create directory:
p = Path("new_directory")
p.mkdir(parents=True, exist_ok=True)

Create file:
p = Path("new_file.txt")
p.write_text("Hello, World!")

Read file:
content = Path("file.txt").read_text()
print(content)

Delete file:
Path("old_file.txt").unlink()

Delete directory:
Path("old_directory").rmdir()

========================================
3. FILE AND DIRECTORY MANAGEMENT
========================================

Copy Files

Using shutil:
import shutil

Copy file:
shutil.copy("source.txt", "destination.txt")

Copy with permissions:
shutil.copy2("source.txt", "destination.txt")

Copy directory:
shutil.copytree("source_dir", "dest_dir")

Move Files

Move file:
shutil.move("source.txt", "destination.txt")

Rename file:
shutil.move("old_name.txt", "new_name.txt")

Delete Files and Directories

Delete file:
import os
os.remove("file.txt")

Delete directory (must be empty):
os.rmdir("empty_dir")

Delete directory with contents:
import shutil
shutil.rmtree("directory_with_files")

List Directory

List files:
import os
files = os.listdir(".")
for file in files:
    print(file)

Get absolute path:
import os
abs_path = os.path.abspath("file.txt")
print(abs_path)

Find files matching pattern:
import glob
python_files = glob.glob("*.py")
for file in python_files:
    print(file)

========================================
4. FILE PERMISSIONS
========================================

Using os Module

Get permissions:
import os
import stat

permissions = os.stat("file.txt").st_mode
print(oct(permissions))

Change permissions:
os.chmod("file.txt", 0o644)

Permission values:
0o755 = rwxr-xr-x (executables)
0o644 = rw-r--r-- (regular files)
0o600 = rw------- (private files)
0o700 = rwx------ (private dirs)

Check if readable:
import os
import stat

st = os.stat("file.txt")
is_readable = bool(st.st_mode & stat.S_IRUSR)
print(f"Readable: {is_readable}")

Check if executable:
is_executable = bool(st.st_mode & stat.S_IXUSR)
print(f"Executable: {is_executable}")

Practical Example

Make file executable:
import os
import stat

script_path = "deploy.sh"
st = os.stat(script_path)
os.chmod(script_path, st.st_mode | stat.S_IEXEC)

========================================
5. ENVIRONMENT VARIABLES
========================================

Reading Environment Variables

Get variable:
import os

home = os.getenv("HOME")
user = os.getenv("USER")
path = os.getenv("PATH")
print(f"Home: {home}")
print(f"User: {user}")

Get with default:
debug = os.getenv("DEBUG", "false")

Get all variables:
all_vars = os.environ
for key, value in all_vars.items():
    print(f"{key}={value}")

Setting Environment Variables

Set in Python session:
import os
os.environ["CUSTOM_VAR"] = "value"

Using .env Files

Create .env file:
DATABASE_HOST=localhost
DATABASE_USER=admin
DATABASE_PASSWORD=secret
API_KEY=xyz123

Load .env file:
from pathlib import Path
from dotenv import load_dotenv
import os

env_file = Path(__file__).parent / ".env"
load_dotenv(env_file)

db_host = os.getenv("DATABASE_HOST")
db_user = os.getenv("DATABASE_USER")
print(f"Database: {db_host}, User: {db_user}")

Install python-dotenv:
pip install python-dotenv

========================================
6. PROCESS MANAGEMENT
========================================

List Processes

Get process info:
import subprocess

result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
processes = result.stdout
print(processes)

Find process by name:
result = subprocess.run(["ps", "aux"], capture_output=True, text=True)
lines = result.stdout.split("\n")
for line in lines:
    if "nginx" in line:
        print(line)

Using psutil (third-party):

Install:
pip install psutil

List processes:
import psutil

for proc in psutil.process_iter(['pid', 'name']):
    print(f"PID: {proc.info['pid']}, Name: {proc.info['name']}")

Get process by name:
def find_process(name):
    for proc in psutil.process_iter(['name']):
        if proc.info['name'] == name:
            return proc
    return None

nginx = find_process("nginx")
if nginx:
    print(f"Found nginx with PID {nginx.pid}")

Kill process:
import os
import signal

os.kill(pid, signal.SIGTERM)

Memory usage:
import psutil

proc = psutil.Process(pid)
mem_info = proc.memory_info()
print(f"Memory: {mem_info.rss / 1024 / 1024} MB")

========================================
7. SYSTEM INFORMATION
========================================

OS Information

Import:
import platform
import os

Operating system:
os_name = os.name
system = platform.system()
release = platform.release()
version = platform.version()

print(f"OS: {os_name}")
print(f"System: {system}")
print(f"Release: {release}")
print(f"Version: {version}")

CPU Information

Processor:
processor = platform.processor()
print(f"Processor: {processor}")

CPU count:
import os
cpu_count = os.cpu_count()
print(f"CPU cores: {cpu_count}")

Using psutil:
import psutil

cpu_percent = psutil.cpu_percent(interval=1)
print(f"CPU usage: {cpu_percent}%")

cpu_count = psutil.cpu_count()
print(f"CPU cores: {cpu_count}")

Memory Information

Virtual memory:
import psutil

memory = psutil.virtual_memory()
print(f"Total: {memory.total / 1024**3:.2f} GB")
print(f"Used: {memory.used / 1024**3:.2f} GB")
print(f"Percent: {memory.percent}%")

Disk Information

Disk usage:
import psutil

disk = psutil.disk_usage("/")
print(f"Total: {disk.total / 1024**3:.2f} GB")
print(f"Used: {disk.used / 1024**3:.2f} GB")
print(f"Free: {disk.free / 1024**3:.2f} GB")

========================================
8. LOGGING
========================================

Basic Logging

Import:
import logging

Configure:
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

Log messages:
logging.debug("Debug message")
logging.info("Info message")
logging.warning("Warning message")
logging.error("Error message")
logging.critical("Critical message")

Log to file:
logging.basicConfig(
    filename='app.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

Both file and console:
import logging

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

file_handler = logging.FileHandler('app.log')
file_handler.setLevel(logging.INFO)

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.DEBUG)

formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
file_handler.setFormatter(formatter)
console_handler.setFormatter(formatter)

logger.addHandler(file_handler)
logger.addHandler(console_handler)

logger.info("Application started")

========================================
9. PRACTICAL SYSADMIN SCRIPTS
========================================

Script 1: System Info Reporter

Create file: system_info.py

#!/usr/bin/env python3

import platform
import psutil
import subprocess
from pathlib import Path

def get_system_info():
    info = {
        "hostname": subprocess.run(["hostname"], capture_output=True, text=True).stdout.strip(),
        "system": platform.system(),
        "release": platform.release(),
        "cpu_cores": psutil.cpu_count(),
        "cpu_percent": psutil.cpu_percent(interval=1),
        "memory_percent": psutil.virtual_memory().percent,
        "disk_percent": psutil.disk_usage("/").percent
    }
    return info

if __name__ == "__main__":
    info = get_system_info()
    for key, value in info.items():
        print(f"{key}: {value}")

Run:
python3 system_info.py

Script 2: Service Status Checker

Create file: check_services.py

#!/usr/bin/env python3

import subprocess
import sys

services = ["nginx", "mysql", "redis"]

def check_service(service_name):
    result = subprocess.run(
        ["systemctl", "is-active", service_name],
        capture_output=True,
        text=True
    )
    return result.returncode == 0

if __name__ == "__main__":
    for service in services:
        status = "running" if check_service(service) else "stopped"
        print(f"{service}: {status}")

Script 3: Backup Script

Create file: backup.py

#!/usr/bin/env python3

import shutil
from pathlib import Path
from datetime import datetime

def backup_directory(source, destination):
    source_path = Path(source)
    if not source_path.exists():
        print(f"Source {source} not found")
        return False
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_name = f"{source_path.name}_{timestamp}"
    dest_path = Path(destination) / backup_name
    
    shutil.copytree(source, dest_path)
    print(f"Backup created: {dest_path}")
    return True

if __name__ == "__main__":
    backup_directory("./data", "./backups")

Script 4: Log File Analyzer

Create file: analyze_logs.py

#!/usr/bin/env python3

from pathlib import Path
import sys

def analyze_log(filename):
    path = Path(filename)
    
    if not path.exists():
        print(f"File {filename} not found")
        return
    
    with open(path, "r") as f:
        lines = f.readlines()
    
    error_count = sum(1 for line in lines if "ERROR" in line)
    warning_count = sum(1 for line in lines if "WARNING" in line)
    info_count = sum(1 for line in lines if "INFO" in line)
    
    print(f"Total lines: {len(lines)}")
    print(f"Errors: {error_count}")
    print(f"Warnings: {warning_count}")
    print(f"Info: {info_count}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 analyze_logs.py <logfile>")
        sys.exit(1)
    
    analyze_log(sys.argv[1])

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Subprocess module for commands
- Pathlib for path operations
- File and directory management
- File permissions
- Environment variables
- Process management
- System information
- Logging

Skills Practiced:
- Running system commands from Python
- File operations
- Process monitoring
- System monitoring
- Log analysis
- Service checking

Practical Scripts Created:
- system_info.py: System information
- check_services.py: Service status
- backup.py: Directory backup
- analyze_logs.py: Log analysis

========================================
NEXT STEPS: Day 3 - APIs and Data Formats
========================================
