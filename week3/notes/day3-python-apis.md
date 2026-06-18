DAY 3: PYTHON FOR APIS AND DATA FORMATS
Command Reference and Learning Notes

LEARNING DATE: June 14, 2026
COMPLETED BY: Iman

========================================
1. REQUESTS LIBRARY BASICS
========================================

What is Requests?
- HTTP library for making API calls
- Simpler than urllib
- Handles JSON automatically
- Excellent error handling

Installation

Install requests:
pip install requests

Verify installation:
python3 -c "import requests; print(requests.__version__)"

Expected output:
2.x.x

Basic GET Request

Simple GET:
import requests

response = requests.get("https://api.example.com/users")
print(response.status_code)
print(response.text)

With status code check:
response = requests.get("https://jsonplaceholder.typicode.com/users/1")

if response.status_code == 200:
    print("Request successful")
else:
    print(f"Error: {response.status_code}")

Response Properties

Status code:
response.status_code

Response text:
response.text

Response as JSON:
data = response.json()

Headers:
response.headers

URL:
response.url

Elapsed time:
response.elapsed.total_seconds()

Practical Example

Get user data:
import requests

response = requests.get("https://jsonplaceholder.typicode.com/users/1")
if response.status_code == 200:
    user = response.json()
    print(f"Name: {user['name']}")
    print(f"Email: {user['email']}")

========================================
2. REQUEST PARAMETERS
========================================

URL Parameters (Query String)

Using params:
import requests

params = {
    "page": 1,
    "limit": 10
}

response = requests.get("https://api.example.com/users", params=params)
print(response.url)

Manual query string:
response = requests.get("https://api.example.com/users?page=1&limit=10")

Headers

Custom headers:
import requests

headers = {
    "User-Agent": "DevOps-Script/1.0",
    "Accept": "application/json"
}

response = requests.get("https://api.example.com/users", headers=headers)

Content type:
headers = {
    "Content-Type": "application/json"
}

========================================
3. POST REQUESTS
========================================

Send JSON Data

Basic POST:
import requests

data = {
    "name": "Iman",
    "email": "iman@example.com"
}

response = requests.post("https://jsonplaceholder.typicode.com/users", json=data)
print(response.status_code)
print(response.json())

Expected status:
201 (Created)

Send Form Data

Form submission:
import requests

data = {
    "username": "iman",
    "password": "secret123"
}

response = requests.post("https://api.example.com/login", data=data)

With files:
files = {
    "file": open("script.sh", "rb")
}

response = requests.post("https://api.example.com/upload", files=files)

========================================
4. ERROR HANDLING
========================================

Try/Except Pattern

Basic error handling:
import requests

try:
    response = requests.get("https://api.example.com/users")
    response.raise_for_status()
except requests.exceptions.HTTPError as e:
    print(f"HTTP error: {e}")
except requests.exceptions.ConnectionError:
    print("Connection error")
except requests.exceptions.Timeout:
    print("Request timeout")
except requests.exceptions.RequestException as e:
    print(f"Error: {e}")

Check status before processing:
response = requests.get("https://jsonplaceholder.typicode.com/users/1")

if response.status_code == 200:
    user = response.json()
    print(user["name"])
else:
    print(f"Failed with status {response.status_code}")

Handle JSON errors:
try:
    data = response.json()
except ValueError:
    print("Response is not valid JSON")

Timeout handling:
try:
    response = requests.get("https://api.example.com/slow", timeout=5)
except requests.exceptions.Timeout:
    print("Request took too long")

========================================
5. AUTHENTICATION
========================================

API Keys

Query parameter:
import requests

api_key = "your-api-key-here"
params = {"api_key": api_key}

response = requests.get("https://api.example.com/users", params=params)

Header authentication:
headers = {
    "Authorization": f"Bearer {api_key}"
}

response = requests.get("https://api.example.com/users", headers=headers)

Basic Authentication

Using auth parameter:
import requests

response = requests.get(
    "https://api.example.com/users",
    auth=("username", "password")
)

Manual header:
import base64

credentials = base64.b64encode(b"username:password").decode()
headers = {
    "Authorization": f"Basic {credentials}"
}

Token Authentication

Store token:
import requests

def get_auth_header(token):
    return {
        "Authorization": f"Bearer {token}"
    }

token = "your-token-here"
headers = get_auth_header(token)

response = requests.get("https://api.example.com/users", headers=headers)

Environment Variables

From .env file:
from pathlib import Path
from dotenv import load_dotenv
import os
import requests

env_file = Path(__file__).parent / ".env"
load_dotenv(env_file)

api_key = os.getenv("API_KEY")
headers = {
    "Authorization": f"Bearer {api_key}"
}

response = requests.get("https://api.example.com/users", headers=headers)

========================================
6. JSON DATA PROCESSING
========================================

Parse JSON Response

Access fields:
import requests

response = requests.get("https://jsonplaceholder.typicode.com/users/1")
user = response.json()

print(user["name"])
print(user["email"])
print(user["id"])

Access nested data:
data = {
    "user": {
        "profile": {
            "name": "Iman",
            "email": "iman@example.com"
        }
    }
}

name = data["user"]["profile"]["name"]
print(name)

Safe access:
name = user.get("name", "Unknown")
email = user.get("email", "No email")

List of objects:
import requests

response = requests.get("https://jsonplaceholder.typicode.com/users")
users = response.json()

for user in users:
    print(f"{user['name']} - {user['email']}")

Filter data:
users = [u for u in users if u["id"] > 5]

Extract field:
names = [u["name"] for u in users]

Build JSON

Create dictionary:
import json

data = {
    "name": "Iman",
    "role": "DevOps",
    "servers": ["web1", "web2"],
    "config": {
        "timeout": 30,
        "retries": 3
    }
}

Send as JSON:
import requests

response = requests.post(
    "https://jsonplaceholder.typicode.com/posts",
    json=data
)

Convert to string:
json_string = json.dumps(data, indent=2)
print(json_string)

========================================
7. WORKING WITH REST APIs
========================================

API Concepts

REST API structure:
GET /api/users - Get all users
GET /api/users/1 - Get user by ID
POST /api/users - Create user
PUT /api/users/1 - Update user
DELETE /api/users/1 - Delete user

Common status codes:
200 - OK
201 - Created
204 - No Content
400 - Bad Request
401 - Unauthorized
403 - Forbidden
404 - Not Found
500 - Server Error

Example: CRUD Operations

Create (POST):
import requests

new_user = {
    "name": "Alice",
    "email": "alice@example.com"
}

response = requests.post(
    "https://jsonplaceholder.typicode.com/users",
    json=new_user
)
print(f"Created: {response.status_code}")

Read (GET):
response = requests.get("https://jsonplaceholder.typicode.com/users/1")
user = response.json()
print(user)

Update (PUT):
updated_user = {
    "name": "Bob",
    "email": "bob@example.com"
}

response = requests.put(
    "https://jsonplaceholder.typicode.com/users/1",
    json=updated_user
)
print(f"Updated: {response.status_code}")

Delete (DELETE):
response = requests.delete("https://jsonplaceholder.typicode.com/users/1")
print(f"Deleted: {response.status_code}")

Pagination

Handle paginated results:
import requests

page = 1
limit = 10
all_users = []

while page <= 3:
    params = {
        "page": page,
        "limit": limit
    }

    response = requests.get("https://api.example.com/users", params=params)
    users = response.json()

    if not users:
        break

    all_users.extend(users)
    page += 1

print(f"Total users: {len(all_users)}")

========================================
8. PRACTICAL API SCRIPTS
========================================

Script 1: Weather Data Fetcher

Create file: fetch_weather.py

#!/usr/bin/env python3

import requests
import sys

def get_weather(city):
    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude": 42.6977,
        "longitude": 23.3219,
        "current": "temperature_2m,weather_code"
    }

    response = requests.get(url, params=params)

    if response.status_code == 200:
        data = response.json()
        current = data["current"]
        print(f"Temperature: {current['temperature_2m']}C")
        print(f"Weather: {current['weather_code']}")
    else:
        print(f"Error: {response.status_code}")

if __name__ == "__main__":
    get_weather("Sofia")

Run:
python3 fetch_weather.py

Script 2: GitHub User Lookup

Create file: github_lookup.py

#!/usr/bin/env python3

import requests
import sys

def get_github_user(username):
    url = f"https://api.github.com/users/{username}"

    try:
        response = requests.get(url, timeout=5)
        response.raise_for_status()

        user = response.json()
        print(f"Name: {user.get('name', 'N/A')}")
        print(f"Bio: {user.get('bio', 'N/A')}")
        print(f"Public Repos: {user['public_repos']}")
        print(f"Followers: {user['followers']}")

    except requests.exceptions.HTTPError as e:
        print(f"User not found: {e}")
    except requests.exceptions.RequestException as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 github_lookup.py <username>")
        sys.exit(1)

    get_github_user(sys.argv[1])

Run:
python3 github_lookup.py torvalds

Script 3: JSON Configuration Manager

Create file: config_manager.py

#!/usr/bin/env python3

import json
from pathlib import Path

class ConfigManager:
    def __init__(self, filename):
        self.path = Path(filename)
        self.data = {}

    def load(self):
        if self.path.exists():
            with open(self.path, "r") as f:
                self.data = json.load(f)
        else:
            self.data = {}

    def save(self):
        with open(self.path, "w") as f:
            json.dump(self.data, f, indent=2)

    def get(self, key, default=None):
        return self.data.get(key, default)

    def set(self, key, value):
        self.data[key] = value

    def __repr__(self):
        return json.dumps(self.data, indent=2)

if __name__ == "__main__":
    config = ConfigManager("config.json")
    config.load()

    config.set("api_key", "secret123")
    config.set("timeout", 30)
    config.set("retries", 3)

    config.save()
    print(config)

Script 4: API Data Aggregator

Create file: api_aggregator.py

#!/usr/bin/env python3

import requests
import json
from datetime import datetime

def fetch_posts():
    url = "https://jsonplaceholder.typicode.com/posts"
    response = requests.get(url)
    return response.json() if response.status_code == 200 else []

def fetch_users():
    url = "https://jsonplaceholder.typicode.com/users"
    response = requests.get(url)
    return response.json() if response.status_code == 200 else []

def aggregate_data():
    posts = fetch_posts()
    users = fetch_users()

    user_map = {u["id"]: u["name"] for u in users}

    aggregated = []
    for post in posts[:5]:
        aggregated.append({
            "title": post["title"],
            "author": user_map.get(post["userId"], "Unknown"),
            "body": post["body"][:50] + "..."
        })

    data = {
        "timestamp": datetime.now().isoformat(),
        "posts": aggregated,
        "total_posts": len(posts)
    }

    with open("aggregated_data.json", "w") as f:
        json.dump(data, f, indent=2)

    print("Data aggregated to aggregated_data.json")

if __name__ == "__main__":
    aggregate_data()

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Topics Covered:
- Requests library for HTTP calls
- GET, POST, PUT, DELETE requests
- URL parameters and headers
- Error handling and timeouts
- API key and token authentication
- JSON data processing
- REST API concepts (CRUD)
- Pagination handling
- Practical API scripts

Skills Practiced:
- Making HTTP requests
- Handling API responses
- Error handling
- Authentication methods
- JSON parsing
- API data aggregation
- Configuration management

Practical Scripts Created:
- fetch_weather.py: Weather data retrieval
- github_lookup.py: GitHub user lookup
- config_manager.py: JSON config handling
- api_aggregator.py: Multi-API data aggregation

========================================
NEXT STEPS: Day 4 - Python Libraries and Packages
========================================
