# Using the official NGINX alpine image as the base image for smaller image size to make it more lightweith,
# less number of security vulnerabilities, etc.:
FROM nginx:alpine

WORKDIR /src

# Copying NGINX configuration and index.html file to the container:
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./index.html /scarf_hello/