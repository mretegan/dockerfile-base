# DOCKER-VERSION 1.0

# Base image for other DIT4C platform images
FROM fedora:20
MAINTAINER t.dettrick@uq.edu.au

# Install DNF to make this quicker
RUN yum install -y dnf
# Update all packages
RUN dnf upgrade -y

# Run install script inside the container
COPY install.sh /tmp/install.sh
COPY easydav_fix-archive-download.patch /tmp/
RUN bash /tmp/install.sh

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY opt /opt
COPY var /var
# Chowned to root, so reverse that change
RUN chown -R researcher /var/log/easydav /var/log/supervisor
RUN chown -R nginx /var/lib/nginx

EXPOSE 23 80
# Run all processes through supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
