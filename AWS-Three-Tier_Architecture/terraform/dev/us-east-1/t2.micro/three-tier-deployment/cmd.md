<!-- Here is an example of a Terraform userdata script that can be used to launch an EC2 instance with an 
Apache web server and display an image on the server:

#!/bin/bash

yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

echo "<html><body><img src='https://www.example.com/image.jpg' alt='Example Image'></body></html>" > /var/www/html/index.html

aws s3 cp s3://my-bucket/image.jpg /var/www/html/image.jpg


You can replace https://www.example.com/image.jpg with the URL of your image and s3://my-bucket/image.jpg 
with the path to the image in your S3 bucket.

This script will update the server, install Apache web server, start the service and enable it to start on 
boot, create an index.html file with an img tag, and download an image from the S3 and place it in 
the /var/www/html/image.jpg and image will be displayed on the web server.

Please note that you will need to configure your EC2 security group to allow traffic on port 80 for the 
Apache web server to function correctly. -->


<!-- Here is another example of a Terraform userdata script that will install an Apache web server and display 
an image on the homepage:

#!/bin/bash

sudo apt-get update
sudo apt-get -y install apache2

sudo echo "<html><body><img src='https://www.example.com/image.jpg' alt='My Image'/></body></html>" > /var/www/html/index.html

sudo service apache2 restart


This script first updates the package manager and installs Apache. Then, it creates an HTML file in the 
default web directory that displays an image from a specified URL. Finally, it restarts the Apache service 
to apply the changes.

Please note that you should replace the example image url with the real url of your image.
You should also make sure the instance has internet access to download the image. -->