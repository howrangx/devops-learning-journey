DAY 1: NETWORKING FUNDAMENTALS
Command Reference and Learning Notes

LEARNING DATE: June 4, 2026
COMPLETED BY: Iman

========================================
1. OSI MODEL
========================================

The OSI (Open Systems Interconnection) model has 7 layers:

Layer 7: Application (HTTP, HTTPS, FTP, DNS, SMTP)
Layer 6: Presentation (Encryption, compression)
Layer 5: Session (Dialog control, connection management)
Layer 4: Transport (TCP, UDP)
Layer 3: Network (IP, routing)
Layer 2: Data Link (MAC addresses, switching)
Layer 1: Physical (Cables, signals)

TCP/IP Model (Simplified):
- Application Layer (HTTP, HTTPS, FTP, DNS)
- Transport Layer (TCP, UDP)
- Internet Layer (IP)
- Link Layer (Ethernet, MAC addresses)

========================================
2. TCP/IP FUNDAMENTALS
========================================

IP (Internet Protocol)
- Layer 3 (Network layer)
- Responsible for routing packets
- Two versions: IPv4 and IPv6

IPv4 Addresses
Format: XXX.XXX.XXX.XXX
Range: 0.0.0.0 to 255.255.255.255
Example: 192.168.1.1

IPv6 Addresses
Format: Hexadecimal, colon-separated
Example: 2001:0db8:85a3:0000:0000:8a2e:0370:7334

TCP (Transmission Control Protocol)
- Layer 4 (Transport layer)
- Connection-oriented
- Reliable delivery
- In-order delivery
- Flow control
- Used by: HTTP, HTTPS, FTP, SMTP, SSH

UDP (User Datagram Protocol)
- Layer 4 (Transport layer)
- Connectionless
- Fast but unreliable
- No acknowledgment
- Lower overhead
- Used by: DNS queries, video streaming, online games

Ports
- 0-1023: Well-known ports (HTTP 80, HTTPS 443)
- 1024-49151: Registered ports
- 49152-65535: Dynamic/private ports

Common Ports:
22 = SSH
80 = HTTP
443 = HTTPS
53 = DNS
3306 = MySQL
5432 = PostgreSQL
6379 = Redis
8080 = Alternate HTTP
9200 = Elasticsearch

TCP Three-Way Handshake
1. Client sends SYN to server
2. Server responds with SYN-ACK
3. Client sends ACK
Connection established

========================================
3. DNS (Domain Name System)
========================================

Purpose
- Translates domain names to IP addresses
- Distributed hierarchical system
- Port 53 (UDP or TCP)

DNS Resolution Process
1. Client queries local resolver
2. Resolver queries root nameserver
3. Root returns TLD (Top-Level Domain) server
4. TLD returns authoritative nameserver
5. Authoritative server returns IP address
6. Resolver returns IP to client

DNS Record Types
A = IPv4 address (example.com -> 192.0.2.1)
AAAA = IPv6 address
CNAME = Canonical name (alias)
MX = Mail exchange
NS = Nameserver
TXT = Text record
SOA = Start of Authority

DNS Hierarchy
Root nameservers
  |
Top-Level Domain (TLD) servers (.com, .org, .net)
  |
Authoritative nameservers (your-domain.com)

DNS Caching
- Resolvers cache DNS records
- TTL (Time To Live) determines cache duration
- Faster subsequent lookups
- Reduces DNS server load

========================================
4. HTTP/HTTPS
========================================

HTTP (HyperText Transfer Protocol)
- Layer 7 (Application layer)
- Port 80
- Stateless protocol
- Request-response model
- Not encrypted (plain text)

HTTPS (HTTP Secure)
- Layer 7 (Application layer)
- Port 443
- HTTP with TLS/SSL encryption
- Secures data in transit
- Requires certificate

HTTP Request Methods
GET = Retrieve data (idempotent)
POST = Submit data (creates resource)
PUT = Update entire resource
PATCH = Partial update
DELETE = Remove resource
HEAD = Like GET but no body
OPTIONS = Describe communication options

HTTP Status Codes
1xx = Informational
2xx = Success (200 OK, 201 Created, 204 No Content)
3xx = Redirection (301 Moved, 302 Found, 304 Not Modified)
4xx = Client error (400 Bad Request, 401 Unauthorized, 403 Forbidden, 404 Not Found)
5xx = Server error (500 Server Error, 502 Bad Gateway, 503 Service Unavailable)

HTTP Headers
Content-Type: Type of data (application/json, text/html)
Content-Length: Size of response
Authorization: Authentication credentials
User-Agent: Client information
Accept: Desired response format
Set-Cookie: Store data on client

HTTPS Process
1. Client initiates connection
2. Server sends certificate
3. Client verifies certificate
4. Client and server perform TLS handshake
5. Encrypted connection established
6. HTTP communication encrypted with TLS

========================================
5. NETWORK ADDRESSING
========================================

Subnet Masks
Determine network and host portions of IP
Format: 4 octets (255.255.255.0)
CIDR notation: /24 (24 bits for network)

Common Subnet Masks:
/24 = 255.255.255.0 (256 addresses, 254 usable)
/25 = 255.255.255.128 (128 addresses, 126 usable)
/26 = 255.255.255.192 (64 addresses, 62 usable)
/27 = 255.255.255.224 (32 addresses, 30 usable)
/28 = 255.255.255.240 (16 addresses, 14 usable)

Private IP Ranges
10.0.0.0/8 (10.0.0.0 to 10.255.255.255)
172.16.0.0/12 (172.16.0.0 to 172.31.255.255)
192.168.0.0/16 (192.168.0.0 to 192.168.255.255)

Gateway
Default gateway routes traffic to other networks
Example: 192.168.1.1 (router on home network)

NAT (Network Address Translation)
Translates private IPs to public IP
Allows multiple devices on one public IP
Common on routers and firewalls

========================================
6. NETWORK TOOLS AND COMMANDS
========================================

Getting Network Information

ifconfig (deprecated, use ip)
Shows network interfaces and IP addresses
ifconfig [interface]
ifconfig eth0

ip addr show
Modern way to show IP addresses
ip link show

hostname -I
Show IP address

whois domain.com
Show domain registration info

Getting Interface Details

ip link show
Display network interfaces

ip addr show
Display IP addresses

ethtool eth0
Show interface details and speeds

DNS Queries

nslookup domain.com
Query DNS (older tool)
nslookup -type=MX domain.com

dig domain.com
Modern DNS query tool
dig +short domain.com
dig @8.8.8.8 domain.com (specific nameserver)

host domain.com
Simple hostname to IP lookup

Connectivity Testing

ping 8.8.8.8
Send ICMP echo requests
Tests connectivity and latency

ping -c 4 8.8.8.8
Send 4 pings (useful on Linux)

traceroute example.com
Show path to destination
traceroute -n example.com (IP addresses only)

mtr example.com
Combined ping and traceroute (better visualization)

Port and Connection Testing

netstat
Show network statistics and connections
netstat -tuln (listening ports)
netstat -tuan (all connections)
Deprecated, use ss instead

ss (socket statistics)
Modern replacement for netstat
ss -tuln (listening ports)
ss -tuan (all connections)
ss -tan | grep ESTABLISHED

nc (netcat) or ncat
Test if port is open
nc -zv example.com 80
Check if port 80 is open on example.com

telnet example.com 80
Connect to port
Not recommended (no encryption)

curl
Make HTTP/HTTPS requests
curl https://example.com
curl -I https://example.com (headers only)
curl -X POST -d data https://example.com

wget
Download files
wget https://example.com/file.zip
wget -O newname.zip https://example.com/file.zip

Network Configuration

ifup interface
Bring interface up

ifdown interface
Bring interface down

ip addr add 192.168.1.10/24 dev eth0
Add IP address

ip route show
Show routing table

ip route add default via 192.168.1.1
Set default gateway

========================================
7. FIREWALL AND SECURITY
========================================

Firewall Basics
- Software or hardware barrier
- Filters traffic based on rules
- Allows or denies connections

iptables (Linux)
Configure firewall rules
iptables -L (list rules)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

firewalld (Modern)
Service-based firewall
firewall-cmd --list-all
firewall-cmd --add-service=http

ufw (Ubuntu Firewall)
User-friendly firewall
ufw status
ufw allow 22
ufw enable

Security Concepts
Inbound: Traffic coming into system
Outbound: Traffic leaving system
Stateful: Remembers connections
Stateless: Treats each packet independently

========================================
8. TROUBLESHOOTING NETWORK ISSUES
========================================

Connection Not Working

1. Check interface is up
ip link show

2. Check IP address assigned
ip addr show

3. Check DNS resolution
dig example.com

4. Test connectivity to gateway
ping [default_gateway]

5. Test external connectivity
ping 8.8.8.8

6. Check routing
ip route show

7. Check listening ports
ss -tuln

Slow Connection

1. Check packet loss
ping -c 10 example.com

2. Check latency
ping example.com

3. Show route and latency
mtr example.com

4. Check bandwidth usage
nethogs (if installed)

5. Check DNS query time
dig example.com (check Query time)

Port Issues

Port not responding:
1. Check if service running
ss -tuln | grep :port

2. Check if port is allowed by firewall
ufw status
firewall-cmd --list-all

3. Test from another machine
nc -zv hostname port

Connection Refused

1. Check service is running
ps aux | grep service

2. Check service is listening
ss -tuln | grep :port

3. Check firewall rules
iptables -L
firewall-cmd --list-all

4. Restart service
systemctl restart service_name

========================================
9. CLOUD NETWORKING CONCEPTS
========================================

VPC (Virtual Private Cloud)
- Isolated network environment
- Subnets for organization
- Route tables for traffic control
- Security groups for firewall
- Network ACLs for filtering
- NAT gateways for private instances

Load Balancing
- Distributes traffic across servers
- Improves performance
- Enables high availability
- Types: Layer 4 (TCP/UDP) or Layer 7 (HTTP/HTTPS)

Auto Scaling
- Automatically adjust capacity
- Based on demand
- Scales up for high traffic
- Scales down for low traffic

DNS in Cloud
- Route 53 (AWS DNS service)
- Geo-routing capabilities
- Health checks
- Failover policies

Content Delivery Network (CDN)
- Caches content worldwide
- Reduces latency
- Reduces bandwidth costs
- CloudFront (AWS), Cloudflare, etc.

========================================
10. PRACTICAL NETWORKING EXERCISES
========================================

Exercise 1: Check Your Network
ip addr show
List all network interfaces and IPs

Exercise 2: DNS Resolution
dig example.com
See DNS resolution process

Exercise 3: Test Connectivity
ping -c 4 8.8.8.8
Test internet connectivity

Exercise 4: Trace Route
traceroute example.com
See hops to destination

Exercise 5: Check Open Ports
ss -tuln
List all listening ports

Exercise 6: HTTP Request
curl -I https://www.google.com
Get HTTP headers

Exercise 7: Domain Information
whois example.com
See domain registration

Exercise 8: Port Test
nc -zv example.com 443
Test if HTTPS port open

========================================
HANDS-ON PRACTICE SUMMARY
========================================

Performed exercises:
- Checked network interface configuration
- Tested DNS resolution
- Verified internet connectivity
- Traced network paths
- Examined open ports
- Made HTTP requests
- Tested port accessibility

Key Concepts Learned:
- OSI and TCP/IP models
- IPv4 addressing and subnets
- TCP vs UDP
- DNS resolution process
- HTTP and HTTPS
- Network troubleshooting
- Firewall basics
- Cloud networking concepts

========================================
NEXT STEPS: Day 2 - Git Basics and GitHub
========================================
