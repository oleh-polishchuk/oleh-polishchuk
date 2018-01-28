#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run this script on behalf of root user"
  exit 1
fi

# ------------------- #
#       NodeJS        #
# ------------------- #

# install Node.js
curl -sL https://deb.nodesource.com/setup_9.x | sudo bash -
apt-get install -y nodejs

# ------------------- #
#      dos2unix       #
# ------------------- #

apt-get install -y dos2unix

# ------------------- #
#       NGINX         #
# ------------------- #

apt-get install -y nginx

# configure default site
cat >/etc/nginx/sites-available/default <<EOL
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;

        ##
        # Basic Settings
        ##

        add_header Cache-Control no-cache;

        ##
        # Gzip Settings
        ##

        gzip on;
        gzip_disable "msie6";

        gzip_vary on;
        gzip_proxied any;
        gzip_comp_level 6;
        gzip_buffers 16 8k;
        gzip_http_version 1.1;
        gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript;

        location / {
            root /usr/src/oleh-polishchuk;
            index index.html index.html;
            sendfile off;
        }

        location ~* \.(css)$ {
            root /usr/src/oleh-polishchuk;
            add_header Cache-Control "max-age=31536000";
            sendfile off;
        }

        location ~* \.(js)$ {
            root /usr/src/oleh-polishchuk;
            add_header Cache-Control "private, max-age=31536000";
            sendfile off;
        }

        location ~* \.(jpg|png|gif|ico|svg)$ {
            root /usr/src/oleh-polishchuk;
            add_header Cache-Control "max-age=86400";
            sendfile off;
        }

        location ~* \.(otf|eot|ttf|woff|woff2)$ {
            root /usr/src/oleh-polishchuk;
            sendfile off;
        }

        # Max upload size
        client_max_body_size 100M;
}
EOL

# reload configuration
service nginx reload
