#!/bin/bash

# Update package list and install Nginx if not installed
sudo apt-get update
sudo apt-get install -y nginx

# Ensure Nginx configuration is set to listen on port 80
NGINX_CONF="/etc/nginx/sites-available/default"

if grep -q "listen 80;" $NGINX_CONF; then
    echo "Nginx is already configured to listen on port 80."
else
    sudo sed -i '/listen \[::\]:80 default_server;/a \    listen 80 default_server;' $NGINX_CONF
    echo "Configured Nginx to listen on port 80."
fi

# Check for any port conflicts on port 80 and kill the process if necessary
PORT_80_PROCESS=$(sudo lsof -i tcp:80 | grep LISTEN | awk '{print $2}')

if [ ! -z "$PORT_80_PROCESS" ]; then
    echo "Port 80 is being used by process ID: $PORT_80_PROCESS. Terminating the process."
    sudo kill -9 $PORT_80_PROCESS
fi

# Restart Nginx service using service command
sudo service nginx restart

# Verify if Nginx is running and listening on port 80
if sudo service nginx status | grep -q "active (running)"; then
    echo "Nginx is running."
else
    echo "Nginx failed to start."
    exit 1
fi

# Verify Nginx is listening on port 80
if sudo netstat -tulnp | grep -q ":80 .*nginx"; then
    echo "Nginx is listening on port 80."
else
    echo "Nginx is not listening on port 80. Please check the configuration."
    exit 1
fi

echo "Nginx has been successfully configured to listen on port 80 on all the server’s active IPv4 IPs."

