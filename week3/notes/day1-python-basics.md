DAY 1: PYTHON BASICS AND SETUP
Command Reference and Learning Notes

LEARNING DATE: June 14, 2026
COMPLETED BY: Iman

========================================
1. PYTHON INSTALLATION AND ENVIRONMENT
========================================

Check Python Installation

Verify Python is installed:
python3 --version
python3 --help

Expected output:
Python 3.x.x

Check pip (package manager):
pip3 --version

Expected output:
pip 20.x.x from ...

If not installed:
Linux (Ubuntu/Debian):
sudo apt update
sudo apt install python3 python3-pip python3-venv

macOS:
brew install python3

Windows:
Download from python.org
Or use: choco install python

Setting Up Virtual Environment

Why virtual environments?
- Isolate project dependencies
- Avoid conflicts between projects
- Clean project organization
- Easy to reproduce setup

Create virtual environment:
python3 -m venv devops-venv

Activate virtual environment:

Linux/macOS:
source devops-venv/bin/activate

Windows:
devops-venv\Scripts\activate

Verify activation:
which python (Linux/macOS)
where python (Windows)

Should show path inside devops-venv

Deactivate:
deactivate

Install packages:
pip install package-name
pip install requests
pip install python-dotenv

List installed packages:
pip list

Save dependencies:
pip freeze > requirements.txt

Install from requirements:
pip install -r requirements.txt

========================================
2. PYTHON BASICS
========================================

Variables and Data Types

Strings:
name = "Iman"
message = "Hello, DevOps!"
print(name)
print(message)

Numbers (integers and floats):
count = 42
temperature = 98.6
result = count + temperature
print(result)

Lists (ordered, mutable):
servers = ["web1", "web2", "db1"]
print(servers[0])
servers.append("cache1")
print(servers)

Tuples (ordered, immutable):
coordinates = (10, 20)
print(coordinates[0])

Dictionaries (key-value pairs):
user = {
    "name": "Iman",
    "role": "DevOps",
    "experience": 5
}
print(user["name"])
user["team"] = "Platform"
print(user)

Boolean:
is_active = True
is_deleted = False
print(is_active)

Type checking:
type(variable)
isinstance(variable, str)

========================================
3. CONTROL FLOW
========================================

If/Else Statements

Simple if:
if count > 10:
    print("Count is greater than 10")

If/else:
if status == "running":
    print("Server is running")
else:
    print("Server is stopped")

If/elif/else:
if status == "running":
    print("Running")
elif status == "stopped":
    print("Stopped")
elif status == "paused":
    print("Paused")
else:
    print("Unknown status")

Comparison operators:
== (equal)
!= (not equal)
> (greater than)
< (less than)
>= (greater than or equal)
<= (less than or equal)

Logical operators:
and (both must be true)
or (at least one true)
not (negation)

Example:
if status == "running" and count > 0:
    print("Running with items")

For Loops

Loop through list:
servers = ["web1", "web2", "db1"]
for server in servers:
    print(server)

Loop with index:
for i, server in enumerate(servers):
    print(f"{i}: {server}")

Range loop:
for i in range(5):
    print(i)

Output:
0, 1, 2, 3, 4

While Loops

Simple while:
count = 0
while count < 5:
    print(count)
    count += 1

Break and continue:
for i in range(10):
    if i == 5:
        break
    if i == 2:
        continue
    print(i)

========================================
4. FUNCTIONS
========================================

Function Definition

Simple function:
def greet(name):
    print(f"Hello, {name}!")

greet("Iman")

Function with return:
def add(a, b):
    return a + b

result = add(5, 3)
print(result)

Function with default parameter:
def deploy(service, environment="staging"):
    print(f"Deploying {service} to {environment}")

deploy("app1")
deploy("app1", "production")

Function with multiple parameters:
def create_user(username, email, role="user"):
    return {
        "username": username,
        "email": email,
        "role": role
    }

user = create_user("iman", "iman@example.com", "admin")
print(user)

Docstrings:
def calculate_uptime(online_time, total_time):
    """
    Calculate system uptime percentage.
    
    Args:
        online_time: Time system was online
        total_time: Total monitoring time
    
    Returns:
        Uptime percentage as float
    """
    return (online_time / total_time) * 100

Help:
help(calculate_uptime)

========================================
5. ERROR HANDLING
========================================

Try/Except

Basic error handling:
try:
    result = 10 / 0
except ZeroDivisionError:
    print("Cannot divide by zero")

Catch any error:
try:
    file = open("missing.txt")
except Exception as e:
    print(f"Error: {e}")

Multiple exceptions:
try:
    data = int("abc")
except ValueError:
    print("Invalid number")
except TypeError:
    print("Wrong type")

Finally block:
try:
    file = open("data.txt")
    data = file.read()
except FileNotFoundError:
    print("File not found")
finally:
    print("Cleanup done")

Raise exceptions:
def validate_port(port):
    if port < 1 or port > 65535:
        raise ValueError("Invalid port number")
    return port

try:
    validate_port(99999)
except ValueError as e:
    print(f"Error: {e}")

Common exceptions:
ValueError: Wrong value type
TypeError: Wrong type used
FileNotFoundError: File doesn't exist
KeyError: Dictionary key not found
IndexError: List index out of range
ZeroDivisionError: Division by zero
ConnectionError: Network connection failed
TimeoutError: Operation timed out

========================================
6. MODULES AND IMPORTS
========================================

Standard Library Modules

Import entire module:
import os
print(os.getcwd())
os.chdir("/tmp")

Import specific function:
from os import getcwd, chdir
print(getcwd())

Import with alias:
import datetime as dt
now = dt.datetime.now()
print(now)

Common modules:
os: Operating system operations
sys: System-specific parameters
json: JSON data handling
subprocess: Running external commands
time: Time operations
datetime: Date and time handling
pathlib: Path operations
logging: Logging system
requests: HTTP requests (third-party)

Using os module:
import os

Get environment variables:
home = os.getenv("HOME")
path = os.getenv("PATH")

Run commands:
os.system("ls -la")

Get current directory:
cwd = os.getcwd()

List files:
files = os.listdir(".")

Using datetime:
from datetime import datetime, timedelta

Current time:
now = datetime.now()
print(now)

Format time:
formatted = now.strftime("%Y-%m-%d %H:%M:%S")
print(formatted)

Time delta:
tomorrow = now + timedelta(days=1)
print(tomorrow)

========================================
7. STRING OPERATIONS
========================================

String Methods

Length:
text = "Hello DevOps"
print(len(text))

Case conversion:
text.upper()
text.lower()
text.capitalize()

String splitting:
data = "server1,server2,server3"
servers = data.split(",")
print(servers)

Joining:
servers = ["server1", "server2", "server3"]
data = ",".join(servers)
print(data)

Replace:
text = "Hello World"
new_text = text.replace("World", "DevOps")

Contains:
if "DevOps" in text:
    print("Contains DevOps")

String formatting:

Old style (% operator):
name = "Iman"
message = "Hello, %s" % name

Format method:
message = "Hello, {}".format(name)
message = "Name: {}, Role: {}".format("Iman", "DevOps")

F-strings (modern, preferred):
name = "Iman"
role = "DevOps"
message = f"Hello, {name}! You are a {role} engineer"
print(message)

With calculations:
count = 42
message = f"There are {count * 2} servers"

========================================
8. WORKING WITH FILES
========================================

Reading Files

Read entire file:
with open("data.txt", "r") as file:
    content = file.read()
    print(content)

Read line by line:
with open("data.txt", "r") as file:
    for line in file:
        print(line.strip())

Read all lines:
with open("data.txt", "r") as file:
    lines = file.readlines()
    print(lines[0])

Writing Files

Write to file (overwrite):
with open("output.txt", "w") as file:
    file.write("Hello, DevOps!\n")
    file.write("Line 2\n")

Append to file:
with open("output.txt", "a") as file:
    file.write("Appended line\n")

Check file exists:
import os
if os.path.exists("data.txt"):
    print("File exists")

Get file size:
import os
size = os.path.getsize("data.txt")
print(f"File size: {size} bytes")

Delete file:
import os
os.remove("old-file.txt")

========================================
9. WORKING WITH JSON
========================================

JSON Basics

JSON is text format for data:
{
    "name": "Iman",
    "role": "DevOps",
    "servers": ["web1", "web2"],
    "experience": 5
}

Parse JSON string:
import json

json_string = '{"name": "Iman", "role": "DevOps"}'
data = json.loads(json_string)
print(data["name"])

Convert to JSON string:
data = {
    "name": "Iman",
    "role": "DevOps",
    "servers": ["web1", "web2"]
}

json_string = json.dumps(data, indent=2)
print(json_string)

Read JSON file:
import json

with open("config.json", "r") as file:
    config = json.load(file)
    print(config["api_key"])

Write JSON file:
import json

data = {
    "host": "localhost",
    "port": 5432,
    "database": "devops"
}

with open("config.json", "w") as file:
    json.dump(data, file, indent=2)

Pretty printing:
json_string = json.dumps(data, indent=2, sort_keys=True)
print(json_string)

========================================
10. HANDS-ON PRACTICE
========================================

Exercise 1: Basic Script

Create file: hello.py

#!/usr/bin/env python3

def greet(name):
    return f"Hello, {name}!"

name = "DevOps"
message = greet(name)
print(message)

Run:
python3 hello.py

Output:
Hello, DevOps!

Exercise 2: Working with Lists

Create file: server_manager.py

#!/usr/bin/env python3

servers = ["web1", "web2", "db1", "cache1"]

print(f"Total servers: {len(servers)}")

print("Server list:")
for i, server in enumerate(servers, 1):
    print(f"{i}. {server}")

if "db1" in servers:
    print("Database server found")

servers.append("api1")
print(f"After adding api1: {servers}")

Exercise 3: Error Handling

Create file: validate_input.py

#!/usr/bin/env python3

def get_positive_number():
    while True:
        try:
            number = int(input("Enter positive number: "))
            if number <= 0:
                raise ValueError("Number must be positive")
            return number
        except ValueError as e:
            print(f"Error: {e}. Try again.")

result = get_positive_number()
print(f"You entered: {result}")

Run:
python3 validate_input.py

Exercise 4: File Operations

Create file: file_analyzer.py

#!/usr/bin/env python3
import os

def count_lines(filename):
    if not os.path.exists(filename):
        raise FileNotFoundError(f"File {filename} not found")
    
    with open(filename, "r") as file:
        lines = file.readlines()
    
    return len(lines)

try:
    count = count_lines("data.txt")
    print(f"File has {count} lines")
except FileNotFoundError as e:
    print(f"Error: {e}")

Exercise 5: JSON Processing

Create file: process_config.py

#!/usr/bin/env python3
import json

def load_config(filename):
    with open(filename, "r") as file:
        config = json.load(file)
    return config

def save_config(filename, config):
    with open(filename, "w") as file:
        json.dump(config, file, indent=2)

config = {
    "app_name": "DevOps Platform",
    "version": "1.0.0",
    "database": {
        "host": "localhost",
        "port": 5432
    }
}

save_config("config.json", config)
loaded = load_config("config.json")
print(json.dumps(loaded, indent=2))

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Python installation and setup
- Virtual environments
- Basic syntax and data types
- Control flow (if/else, loops)
- Functions and parameters
- Error handling (try/except)
- Modules and imports
- String operations
- File operations
- JSON processing

Skills Practiced:
- Writing Python scripts
- Using standard library
- Error handling
- Working with files
- Data processing

Exercises Created:
- hello.py: Basic script
- server_manager.py: Lists and loops
- validate_input.py: Error handling
- file_analyzer.py: File operations
- process_config.py: JSON processing

========================================
NEXT STEPS: Day 2 - Python for System Administration
========================================
