# DOCKER-VERSION 1.0

# Base image for other DIT4C platform images
FROM centos:centos7
MAINTAINER t.dettrick@uq.edu.au

# Update all packages
RUN yum upgrade -y

# Install EPEL repo
RUN rpm -Uvh http://mirror.aarnet.edu.au/pub/epel/beta/7/x86_64/$( \
  curl http://mirror.aarnet.edu.au/pub/epel/7/x86_64/repoview/epel-release.html | \
  grep -Po 'epel-release.*?\.rpm' | head -1)
# Install Nginx repo
RUN rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/$( \
  curl http://nginx.org/packages/centos/7/noarch/RPMS/ | \
  grep -Po 'nginx-release.*?\.rpm' | head -1)
  
# Install
# - supervisord for monitoring
# - nginx for reverse-proxying
# - Git and development tools
# - node.js for TTY.js
# - PIP so we can install EasyDav dependencies
# - patching dependencies
# - sudo (for users installing packages)
RUN yum install -y \
  supervisor \
  nginx \
  git vim-enhanced nano wget tmux screen bash-completion man \
  tar zip unzip \
  nodejs \
  python-pip \
  patch \
  sudo

# Install EasyDAV dependencies
RUN pip install kid flup
# Install NPM
RUN yum install -y tar gcc-c++ && \ 
  curl -L https://npmjs.org/install.sh | clean=no sh

# Install TTY.js with updated term.js
RUN git clone -b single-window  --single-branch https://github.com/dit4c/tty.js.git /opt/tty.js && \
  cd /opt/tty.js && \
  npm install

# Install EasyDAV
COPY easydav_fix-archive-download.patch /tmp/
RUN cd /opt && \
  curl http://koti.kapsi.fi/jpa/webdav/easydav-0.4.tar.gz | tar zxvf - && \
  mv easydav-0.4 easydav && \
  cd easydav && \
  patch -p1 < /tmp/easydav_fix-archive-download.patch && \
  cd -

# Install zedrem
RUN cd /usr/local/bin && \
  curl http://get.zedapp.org | bash && \
  cd -
  
# Create researcher user for notebook
RUN /usr/sbin/useradd researcher

# Log directory for easydav & supervisord
RUN mkdir -p /var/log/{easydav,supervisor}

# Set default password for root, and remove password for researcher
RUN yum install -y passwd && \
  echo 'root:developer' | chpasswd && \
  passwd -d researcher && passwd -u -f researcher

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY opt /opt
COPY var /var
# Set logging directory permissions appropriately
RUN chown -R researcher /var/log/easydav /var/log/supervisor

# Check nginx config is OK
RUN nginx -t

EXPOSE 80
# Run all processes through supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Home & log dirs should be exportable
VOLUME ["/home/researcher", "/var/log"]


