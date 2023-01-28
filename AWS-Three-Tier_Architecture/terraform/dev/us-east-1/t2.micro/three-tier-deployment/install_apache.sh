#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello World from $(hostname -f)" > /var/www/html/index.html

sudo echo "<html><body><img src='https://github.com/olusegun45/4tiers-Network-terra/blob/main/AWS%20Net%20diagram%2010-17-21.jpeg?raw=true' alt='My Image'/></body></html>" > /var/www/html/index.html