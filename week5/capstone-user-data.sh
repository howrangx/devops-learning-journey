#!/bin/bash
dnf install -y httpd awscli
aws s3 cp s3://iman-devops-week5-2026/capstone/index.html /var/www/html/index.html
systemctl start httpd
systemctl enable httpd
