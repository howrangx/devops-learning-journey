DAY 4: PYTHON LIBRARIES AND PACKAGES
Command Reference and Learning Notes

LEARNING DATE: June 18, 2026
COMPLETED BY: Iman

========================================
1. PIP - PYTHON PACKAGE MANAGER
========================================

What is Pip?
- Package installer for Python
- Manages third-party libraries
- Handles dependencies
- Part of Python since 3.4

Verify pip Installation

Check pip version:
pip --version
pip3 --version

Expected output:
pip 20.x.x from ...

Update pip:
python3 -m pip install --upgrade pip

On macOS:
pip install --upgrade pip

On Linux:
sudo apt update
sudo apt install python3-pip

========================================
2. VIRTUAL ENVIRONMENTS
========================================

Why Virtual Environments?

Benefits:
- Isolate project dependencies
- Prevent version conflicts
- Clean project organization
- Easy reproduction
- Per-project configurations

Creating Virtual Environment

Create venv:
python3 -m venv project-env

Or with specific name:
python3 -m venv myproject-venv

Activate Virtual Environment

Linux/macOS:
source project-env/bin/activate

Windows:
project-env\Scripts\activate

Verify activation:
which python (Linux/macOS)
where python (Windows)

Should show path inside project-env

Deactivate Virtual Environment

Simply type:
deactivate

Or create alias:
alias deactivate='deactivate'

Installing with Virtual Environment

With venv activated:
pip install requests
pip install pandas
pip install boto3

Install multiple:
pip install requests pandas boto3

Check installed packages:
pip list

pip freeze (for requirements):
pip freeze

========================================
3. REQUIREMENTS AND DEPENDENCIES
========================================

Create Requirements File

From current environment:
pip freeze > requirements.txt

Manual creation:
echo "requests==2.28.0" > requirements.txt
echo "boto3==1.26.0" >> requirements.txt
echo "pyyaml==6.0" >> requirements.txt

Requirements File Format

Exact versions:
requests==2.28.0
boto3==1.26.0
pyyaml==6.0

Version ranges:
requests>=2.25.0,<3.0.0
boto3~=1.26.0

Install from Requirements

Install all:
pip install -r requirements.txt

Common DevOps requirements.txt:

requests==2.28.0
boto3==1.26.0
pyyaml==6.0
paramiko==2.12.0
jinja2==3.1.2
ansible==5.8.0
terraform==1.0.0
docker==5.0.3
kubernetes==24.2.0
prometheus-client==0.14.0

Setup Development Requirements

Create requirements-dev.txt:
-r requirements.txt
pytest==7.2.0
pytest-cov==3.0.0
black==22.10.0
flake8==5.0.0
mypy==0.990

Install development:
pip install -r requirements-dev.txt

========================================
4. POPULAR DEVOPS LIBRARIES
========================================

AWS - Boto3

Installation:
pip install boto3

Basic usage:
import boto3

client = boto3.client('ec2')
instances = client.describe_instances()

Infrastructure Automation:
import boto3

ec2 = boto3.resource('ec2')
instance = ec2.create_instances(
    ImageId='ami-12345678',
    MinCount=1,
    MaxCount=1
)

Cloud - Azure SDK

Installation:
pip install azure-identity
pip install azure-compute

Basic usage:
from azure.identity import DefaultAzureCredential
from azure.mgmt.compute import ComputeManagementClient

credential = DefaultAzureCredential()
client = ComputeManagementClient(credential, subscription_id)

Containers - Docker SDK

Installation:
pip install docker

Basic usage:
import docker

client = docker.from_env()
containers = client.containers.list()

Container operations:
image = client.images.pull('ubuntu:latest')
container = client.containers.run('ubuntu', 'echo hello')

Kubernetes - Client

Installation:
pip install kubernetes

Basic usage:
from kubernetes import client, config

config.load_kube_config()
v1 = client.CoreV1Api()

pods = v1.list_pod_for_all_namespaces()
for pod in pods.items:
    print(pod.metadata.name)

Configuration - PyYAML

Installation:
pip install pyyaml

Parse YAML:
import yaml

with open('config.yml', 'r') as f:
    config = yaml.safe_load(f)

Write YAML:
import yaml

data = {
    'server': 'localhost',
    'port': 8080,
    'debug': True
}

with open('config.yml', 'w') as f:
    yaml.dump(data, f)

SSH - Paramiko

Installation:
pip install paramiko

SSH connection:
import paramiko

ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('hostname', username='user', password='pass')

stdin, stdout, stderr = ssh.exec_command('ls -la')
print(stdout.read().decode())
ssh.close()

Monitoring - Prometheus Client

Installation:
pip install prometheus-client

Create metric:
from prometheus_client import Counter, Gauge

requests_total = Counter('requests_total', 'Total requests')
cpu_usage = Gauge('cpu_usage', 'CPU usage percentage')

Use metrics:
requests_total.inc()
cpu_usage.set(45.5)

Configuration Management - Jinja2

Installation:
pip install jinja2

Template rendering:
from jinja2 import Template

template = Template('Hello {{ name }}!')
result = template.render(name='DevOps')
print(result)

File templates:
from jinja2 import Environment, FileSystemLoader

env = Environment(loader=FileSystemLoader('templates'))
template = env.get_template('config.j2')
result = template.render(server='localhost', port=8080)

Data Processing - Pandas

Installation:
pip install pandas

Read CSV:
import pandas as pd

df = pd.read_csv('data.csv')
print(df.head())

Data manipulation:
df_filtered = df[df['status'] == 'active']
summary = df.groupby('region').sum()

Testing - Pytest

Installation:
pip install pytest

Write test:
def test_addition():
    assert 2 + 2 == 4

Run tests:
pytest test_file.py
pytest (run all tests)
pytest -v (verbose)
pytest --cov (coverage)

Code Quality - Black and Flake8

Installation:
pip install black flake8

Format code:
black script.py

Check style:
flake8 script.py

Type Checking - Mypy

Installation:
pip install mypy

Add type hints:
def add_numbers(a: int, b: int) -> int:
    return a + b

Check types:
mypy script.py

========================================
5. CREATING YOUR OWN LIBRARY
========================================

Project Structure

project/
├── mylib/
│   ├── __init__.py
│   ├── core.py
│   └── utils.py
├── tests/
│   ├── test_core.py
│   └── test_utils.py
├── setup.py
├── requirements.txt
└── README.md

Basic Module

Create mylib/__init__.py:
from .core import MyClass

__version__ = '0.1.0'
__author__ = 'Your Name'

Create mylib/core.py:
class MyClass:
    def __init__(self, name):
        self.name = name

    def greet(self):
        return f"Hello, {self.name}!"

Create mylib/utils.py:
def format_output(text):
    return text.upper()

Setup File

Create setup.py:
from setuptools import setup, find_packages

setup(
    name='mydevopslib',
    version='0.1.0',
    description='DevOps utility library',
    author='Iman',
    author_email='iman@example.com',
    packages=find_packages(),
    install_requires=[
        'requests>=2.25.0',
        'pyyaml>=5.0'
    ],
    python_requires='>=3.7',
    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],
)

Install Locally

Development install:
pip install -e .

Regular install:
pip install .

Testing Your Library

Create tests/test_core.py:
import pytest
from mylib import MyClass

def test_init():
    obj = MyClass('Iman')
    assert obj.name == 'Iman'

def test_greet():
    obj = MyClass('Iman')
    result = obj.greet()
    assert result == 'Hello, Iman!'

Run tests:
pytest

========================================
6. VERSION MANAGEMENT
========================================

Semantic Versioning

Format: MAJOR.MINOR.PATCH

Examples:
1.0.0 - Initial release
1.1.0 - Add new feature (backward compatible)
1.1.1 - Bug fix
2.0.0 - Breaking changes

Specify Versions in setup.py

Exact version:
install_requires=['requests==2.28.0']

Minimum version:
install_requires=['requests>=2.25.0']

Range:
install_requires=['requests>=2.25.0,<3.0.0']

Compatible release:
install_requires=['requests~=2.28.0']
(means >=2.28.0, <2.29.0)

Managing Multiple Versions

Check current:
python --version

Install specific:
pip install requests==2.28.0

Upgrade package:
pip install --upgrade requests

List outdated:
pip list --outdated

Upgrade all:
pip install --upgrade -r requirements.txt

========================================
7. COMMON DEVOPS PATTERNS
========================================

Pattern 1: AWS S3 Backup Script

Create file: s3_backup.py

#!/usr/bin/env python3

import boto3
from pathlib import Path
from datetime import datetime

def backup_to_s3(local_path, bucket, prefix='backups'):
    s3_client = boto3.client('s3')
    local_file = Path(local_path)

    if not local_file.exists():
        print(f"Error: {local_path} not found")
        return False

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    s3_key = f"{prefix}/{local_file.name}_{timestamp}"

    try:
        s3_client.upload_file(
            str(local_file),
            bucket,
            s3_key
        )
        print(f"Uploaded to s3://{bucket}/{s3_key}")
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

if __name__ == "__main__":
    backup_to_s3('./data.tar.gz', 'my-backup-bucket')

Pattern 2: Configuration Management

Create file: config_loader.py

#!/usr/bin/env python3

import yaml
from pathlib import Path

class ConfigLoader:
    def __init__(self, config_file):
        self.config_path = Path(config_file)
        self.config = {}

    def load(self):
        if not self.config_path.exists():
            raise FileNotFoundError(f"Config {self.config_path} not found")

        with open(self.config_path, 'r') as f:
            self.config = yaml.safe_load(f)

        return self.config

    def get(self, key, default=None):
        return self.config.get(key, default)

    def validate(self, required_keys):
        missing = [k for k in required_keys if k not in self.config]
        if missing:
            raise ValueError(f"Missing required keys: {missing}")
        return True

if __name__ == "__main__":
    loader = ConfigLoader('app-config.yml')
    config = loader.load()
    loader.validate(['server', 'port', 'database'])
    print(f"Server: {loader.get('server')}")

Pattern 3: Kubernetes Operations

Create file: k8s_helper.py

#!/usr/bin/env python3

from kubernetes import client, config
from kubernetes.stream import stream

def get_pods(namespace='default'):
    config.load_kube_config()
    v1 = client.CoreV1Api()

    pods = v1.list_namespaced_pod(namespace)
    return pods.items

def get_pod_logs(name, namespace='default'):
    config.load_kube_config()
    v1 = client.CoreV1Api()

    logs = v1.read_namespaced_pod_log(name, namespace)
    return logs

def exec_in_pod(pod_name, command, namespace='default'):
    config.load_kube_config()
    v1 = client.CoreV1Api()

    exec_command = ['/bin/sh', '-c', command]
    resp = stream(
        v1.connect_get_namespaced_pod_exec,
        pod_name,
        namespace,
        command=exec_command,
        stderr=True,
        stdin=False,
        stdout=True,
        tty=False
    )

    return resp

if __name__ == "__main__":
    pods = get_pods()
    for pod in pods:
        print(pod.metadata.name)

Pattern 4: Docker Container Manager

Create file: docker_manager.py

#!/usr/bin/env python3

import docker
from docker.types import Mount

class DockerManager:
    def __init__(self):
        self.client = docker.from_env()

    def list_containers(self, all=False):
        return self.client.containers.list(all=all)

    def run_container(self, image, command=None, name=None):
        return self.client.containers.run(
            image,
            command=command,
            name=name,
            detach=True
        )

    def stop_container(self, container_id):
        container = self.client.containers.get(container_id)
        container.stop()

    def remove_container(self, container_id):
        container = self.client.containers.get(container_id)
        container.remove()

    def get_logs(self, container_id):
        container = self.client.containers.get(container_id)
        return container.logs().decode()

if __name__ == "__main__":
    manager = DockerManager()
    containers = manager.list_containers()
    for container in containers:
        print(f"{container.name}: {container.status}")

========================================
8. ORGANIZING YOUR DEPENDENCIES
========================================

Production vs Development

requirements.txt (production):
requests==2.28.0
boto3==1.26.0
pyyaml==6.0

requirements-dev.txt (development):
-r requirements.txt
pytest==7.2.0
black==22.10.0
flake8==5.0.0

Installing Both

Install production:
pip install -r requirements.txt

Install with development:
pip install -r requirements-dev.txt

Pinning Versions

Always pin versions in requirements:
GOOD: requests==2.28.0
AVOID: requests (any version)

Why pin:
- Reproducible builds
- Avoid breaking changes
- Production consistency
- Easy rollback

Updating Dependencies

Check for updates:
pip list --outdated

Update one package:
pip install --upgrade boto3

Update all:
pip install --upgrade -r requirements.txt

Test after updating:
pytest
python3 -m flake8 .

========================================
9. BEST PRACTICES
========================================

Use Virtual Environments

Always:
python3 -m venv project-env
source project-env/bin/activate
pip install -r requirements.txt

Never:
pip install globally (except pipx)

Document Dependencies

Always:
- Create requirements.txt
- Specify versions
- Keep updated

Never:
- Assume dependencies
- Use pip without tracking

Version Your Code

Always:
- Use semantic versioning
- Update setup.py
- Tag releases

Example version:
1.0.0
1.1.0 (new feature)
1.1.1 (bug fix)
2.0.0 (breaking change)

Test Your Code

Always:
- Write tests
- Run before committing
- Check code quality

Example:
pytest
black --check .
flake8 .
mypy .

Document Your Library

Always:
- Include README
- Add docstrings
- Provide examples
- Document API

Example docstring:
def deploy_service(name, version):
    '''Deploy a service to production.

    Args:
        name: Service name
        version: Version to deploy

    Returns:
        bool: Success status

    Raises:
        ValueError: If name or version invalid
    '''
    pass

========================================
10. HANDS-ON PRACTICE
========================================

Exercise 1: Create Virtual Environment

mkdir my-project
cd my-project
python3 -m venv venv
source venv/bin/activate
pip install requests boto3 pyyaml
pip freeze > requirements.txt
deactivate

Exercise 2: Create Requirements Files

Create requirements.txt:
echo "requests>=2.25.0" > requirements.txt
echo "boto3>=1.20.0" >> requirements.txt
echo "pyyaml>=5.0" >> requirements.txt

Create requirements-dev.txt:
echo "-r requirements.txt" > requirements-dev.txt
echo "pytest>=7.0.0" >> requirements-dev.txt
echo "black>=22.0.0" >> requirements-dev.txt

Install both:
pip install -r requirements-dev.txt

Exercise 3: Create Simple Library

mkdir mydevopslib
cd mydevopslib

Create mydevopslib/__init__.py:
from .helpers import format_output, validate_input

__version__ = '0.1.0'

Create mydevopslib/helpers.py:
def format_output(text):
    return text.upper()

def validate_input(value, min_val=0, max_val=100):
    if not min_val <= value <= max_val:
        raise ValueError(f"Value must be between {min_val} and {max_val}")
    return True

Create tests/test_helpers.py:
import pytest
from mydevopslib import format_output, validate_input

def test_format_output():
    assert format_output('hello') == 'HELLO'

def test_validate_input():
    assert validate_input(50)
    with pytest.raises(ValueError):
        validate_input(150)

Run tests:
pytest

Exercise 4: AWS Integration

Create s3_upload.py:
import boto3

def upload_file(file_path, bucket):
    s3 = boto3.client('s3')
    s3.upload_file(file_path, bucket, file_path.split('/')[-1])
    print(f"Uploaded {file_path} to {bucket}")

Exercise 5: YAML Configuration

Create config.yml:
server:
  host: localhost
  port: 8080
  debug: true

database:
  host: db.example.com
  port: 5432
  name: myapp

Create load_config.py:
import yaml
from pathlib import Path

def load_config(config_file):
    with open(config_file, 'r') as f:
        return yaml.safe_load(f)

config = load_config('config.yml')
print(f"Server: {config['server']['host']}:{config['server']['port']}")

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Pip and package installation
- Virtual environments
- Requirements files
- Popular DevOps libraries
- Creating your own library
- Version management
- Common DevOps patterns
- Dependency organization
- Best practices

Skills Practiced:
- Managing Python packages
- Creating virtual environments
- Using AWS, Kubernetes, Docker SDKs
- Creating and testing libraries
- Configuration management
- Version control
- Dependency tracking

Practical Scripts Created:
- s3_backup.py: AWS S3 backup
- config_loader.py: Configuration management
- k8s_helper.py: Kubernetes operations
- docker_manager.py: Docker container management

========================================
NEXT STEPS: Day 5 - Practical Automation Scripts
========================================
