dit4c/dit4c-container-base
===============================

[![](https://badge.imagelayers.io/dit4c/dit4c-container-base:latest.svg)](https://imagelayers.io/?images=dit4c/dit4c-container-base:latest)

The base image for DIT4C containers, which includes a [tty-lean.js][tty-lean.js] shell and file uploader, using [dit4c/centos-notroot](https://registry.hub.docker.com/u/dit4c/centos-notroot/) to allow package installation without root privileges.

The essential rules/guidelines that it follows are:

1. Services are started & managed by supervisord.
2. Any web services provided by the container must be accessed via port 8080.
  * Nginx is used to reverse-proxy services on other ports. HTTP, WSGI & FastCGI proxying work fine.
  * As a result of this requirement, web services really need to exist on paths, not on "/".
3. `/home/researcher` should contain as few extraneous files as possible.

[tty-lean.js]: https://github.com/dit4c/tty-lean.js
