# DOCKER-VERSION 1.0

# Base image for other DIT4C platform images
FROM centos:7
MAINTAINER t.dettrick@uq.edu.au

# Create researcher user for notebook
RUN /usr/sbin/useradd researcher && \
  (chown -R researcher:researcher / || true) && \
  curl -L http://portable.proot.me/proot-x86_64 > /usr/sbin/proot && \
  chmod +x /usr/sbin/proot

# Directories that don't need to be preserved in images
VOLUME ["/var/cache/yum"]

USER researcher

# Remove yum setting which blocks man page install
RUN sed -i'' 's/tsflags=nodocs/tsflags=/' /etc/yum.conf

# Update all packages and install docs
# (reinstalling glibc-common would add 100MB and no docs, so it's excluded)
RUN proot -S . yum upgrade -y && \
  rpm -qa | grep -v glibc-common | grep -v filesystem | xargs proot -S . yum reinstall -y

# Install EPEL repo
RUN proot -S . yum install -y http://mirror.aarnet.edu.au/pub/epel/7/x86_64/$(\
  curl http://mirror.aarnet.edu.au/pub/epel/7/x86_64/repoview/epel-release.html | \
  grep -Po 'e/epel-release.*?\.rpm' | head -1)
# Install Nginx repo
RUN proot -S . yum install -y http://nginx.org/packages/centos/7/noarch/RPMS/$(\
  curl http://nginx.org/packages/centos/7/noarch/RPMS/ | \
  grep -Po 'nginx-release.*?\.rpm' | head -1)

# Install
# - supervisord for monitoring
# - nginx for reverse-proxying
# - Git and development tools
# - node.js for TTY.js
# - PIP so we can install EasyDav dependencies
# - patching dependencies
RUN proot -S . yum install -y \
  supervisor \
  nginx \
  git vim-enhanced nano wget tmux screen bash-completion man \
  tar zip unzip \
  nodejs \
  python-pip \
  patch

# Install EasyDAV dependencies
RUN proot -S . pip install kid flup

# Install NPM & tty-lean.js
RUN (proot -S . yum install -y tar gcc-c++ || proot -S . yum install -y tar gcc-c++) && \
  curl -L https://npmjs.org/install.sh | clean=no proot -S . bash && \
  proot -S . npm install -g tty-lean.js && \
  rm -r ~/.npm

# Install EasyDAV
COPY easydav_fix-archive-download.patch /tmp/
RUN cd /opt && \
  curl http://koti.kapsi.fi/jpa/webdav/easydav-0.4.tar.gz | tar zxvf - && \
  mv easydav-0.4 easydav && \
  cd easydav && \
  patch -p1 < /tmp/easydav_fix-archive-download.patch && \
  cd -

# Log directory for easydav & supervisord
RUN mkdir -p /var/log/{easydav,supervisor}

# Add supporting files (directory at a time to improve build speed)
COPY etc /etc
COPY opt /opt
COPY var /var

# Check nginx config is OK
RUN nginx -t

EXPOSE 8080
# Run all processes through supervisord
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]

# Logs do not need to be preserved when exporting
VOLUME ["/var/log"]
