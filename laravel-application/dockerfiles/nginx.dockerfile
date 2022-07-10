FROM nginx:stable-alpine
# Copy configuration file
WORKDIR /etc/nginx/conf.d
COPY nginx/nginx.conf .
RUN mv nginx.conf default.conf
# Copy source code
WORKDIR /var/www/html
COPY src .
