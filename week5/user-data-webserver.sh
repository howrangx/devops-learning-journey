#!/bin/bash
dnf install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<h1>Hello from Week 5 Day 2 - $(hostname)</h1>" > /var/www/html/index.html
