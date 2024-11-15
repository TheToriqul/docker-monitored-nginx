#!/bin/bash

###############################################################################
#
# Docker Monitored NGINX - Comprehensive Command Reference
# Author: Md Toriqul Islam
# Description: Complete reference for Docker commands from basic to advanced
# Note: This is a reference script. Do not execute directly.
#
###############################################################################

#------------------------------------------------------------------------------
# Basic Docker Operations
#------------------------------------------------------------------------------

# Check Docker version and info
docker --version
docker info
docker system info

# List Docker images
docker images
docker image ls

# Pull required images
docker pull nginx:latest
docker pull busybox:latest

# Image management
docker image prune  # Remove unused images
docker image prune -a  # Remove all unused images
docker system prune  # Clean up entire system

#------------------------------------------------------------------------------
# Container Lifecycle Management
#------------------------------------------------------------------------------

# Basic container operations
docker create --name web nginx:latest  # Create container
docker start web  # Start container
docker stop web   # Stop container
docker restart web  # Restart container
docker pause web  # Pause container
docker unpause web  # Unpause container
docker rm web  # Remove container
docker rm -f web  # Force remove running container

# Run containers with different options
# NGINX Web Server
docker run -d \
    --name web \
    -p 80:80 \
    --restart unless-stopped \
    nginx:latest

# Mailer Service
docker run -d \
    --name mailer \
    -p 33333:33333 \
    --restart always \
    mailer-image

# Monitoring Agent
docker run -d \
    --name agent \
    --link web:insideweb \
    --link mailer:insidemailer \
    --restart on-failure:5 \
    watcher-image

#------------------------------------------------------------------------------
# Container Networking
#------------------------------------------------------------------------------

# Network management
docker network ls  # List networks
docker network create monitoring-net  # Create network
docker network connect monitoring-net web  # Connect container to network
docker network disconnect monitoring-net web  # Disconnect container from network
docker network inspect monitoring-net  # Inspect network

# Advanced networking
docker run -d \
    --name web \
    --network monitoring-net \
    --network-alias nginx \
    --dns 8.8.8.8 \
    nginx:latest

#------------------------------------------------------------------------------
# Container Monitoring and Debugging
#------------------------------------------------------------------------------

# Basic monitoring
docker ps  # List running containers
docker ps -a  # List all containers
docker stats  # Show container resource usage
docker top web  # Show container processes

# Logging
docker logs web  # View container logs
docker logs -f web  # Follow log output
docker logs --since 5m web  # Show logs from last 5 minutes
docker logs --tail 100 web  # Show last 100 log lines
docker logs --timestamps web  # Show logs with timestamps

# Debugging
docker inspect web  # Inspect container configuration
docker inspect --format='{{.State.Status}}' web  # Get specific information
docker port web  # Show port mappings
docker diff web  # Show changed files in container

# Execute commands in running containers
docker exec -it web bash  # Interactive shell
docker exec web nginx -t  # Test NGINX configuration
docker exec web nginx -s reload  # Reload NGINX configuration

#------------------------------------------------------------------------------
# Image Building and Management
#------------------------------------------------------------------------------

# Building images
docker build -t mailer-image ./mailer  # Basic build
docker build --no-cache -t mailer-image ./mailer  # Build without cache
docker build --build-arg VERSION=1.0 -t mailer-image ./mailer  # Build with arguments

# Image management
docker tag mailer-image:latest mailer-image:v1.0  # Tag image
docker rmi mailer-image:latest  # Remove image
docker save mailer-image > mailer-image.tar  # Save image to file
docker load < mailer-image.tar  # Load image from file

#------------------------------------------------------------------------------
# Volume Management
#------------------------------------------------------------------------------

# Volume operations
docker volume create nginx-config  # Create volume
docker volume ls  # List volumes
docker volume inspect nginx-config  # Inspect volume
docker volume rm nginx-config  # Remove volume

# Mount volumes in containers
docker run -d \
    --name web \
    -v nginx-config:/etc/nginx \
    -v nginx-logs:/var/log/nginx \
    nginx:latest

#------------------------------------------------------------------------------
# Health Checks and Monitoring
#------------------------------------------------------------------------------

# Configure health checks
docker run -d \
    --name web \
    --health-cmd="curl -f http://localhost/ || exit 1" \
    --health-interval=5s \
    --health-retries=3 \
    --health-timeout=2s \
    --health-start-period=30s \
    nginx:latest

# Monitor health status
docker inspect --format='{{.State.Health.Status}}' web
docker events --filter 'container=web'  # Monitor container events

#------------------------------------------------------------------------------
# Resource Management
#------------------------------------------------------------------------------

# Set resource limits
docker run -d \
    --name web \
    --memory="512m" \
    --memory-swap="1g" \
    --cpus="1.5" \
    --pids-limit=100 \
    nginx:latest

# Update resource limits
docker update --memory="1g" --cpus="2" web

#------------------------------------------------------------------------------
# Security and Access Control
#------------------------------------------------------------------------------

# Run containers with security options
docker run -d \
    --name web \
    --security-opt=no-new-privileges \
    --cap-drop ALL \
    --cap-add NET_BIND_SERVICE \
    nginx:latest

# User management
docker run -d \
    --name web \
    --user nginx \
    nginx:latest

#------------------------------------------------------------------------------
# Maintenance and Cleanup
#------------------------------------------------------------------------------

# Container cleanup
docker container prune  # Remove stopped containers
docker container prune --filter "until=24h"  # Remove containers older than 24h

# System maintenance
docker system df  # Show Docker disk usage
docker system prune -a --volumes  # Clean entire system including volumes
docker kill $(docker ps -q)  # Stop all running containers

#------------------------------------------------------------------------------
# Testing and Debugging Tools
#------------------------------------------------------------------------------

# Interactive debugging container
docker run -it \
    --name debugger \
    --net container:web \
    --pid container:web \
    busybox:latest /bin/sh

# Network debugging
docker run --rm \
    --net container:web \
    busybox:latest ping -c 4 google.com

# Test NGINX configuration
docker run --rm \
    -v nginx-config:/etc/nginx \
    nginx:latest nginx -t

###############################################################################
# Advanced Troubleshooting Commands
###############################################################################

# Get container metrics
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Check container logs for specific patterns
docker logs web 2>&1 | grep ERROR
docker logs web 2>&1 | grep -i warning

# Monitor container events in real-time
docker events --filter 'type=container' --format '{{json .}}'

# Export container filesystem
docker export web > web-container.tar

# Import container filesystem
cat web-container.tar | docker import - web-image:latest

###############################################################################
# End of Command Reference
###############################################################################