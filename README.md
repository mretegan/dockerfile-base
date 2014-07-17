dockerfile-dit4c-container-base
===============================

The base image for DIT4C containers.

The essential rules/guidelines that it follows are:

1. Services are started & managed by supervisord.
2. Any web services provided by the container must be accessed via port 80.
  * Nginx is used to reverse-proxy services on other ports. HTTP, WSGI & FastCGI proxying work fine.
  * As a result of this requirement, web services really need to exist on paths, not on "/".
3. `/home/researcher` should contain as few extraneous files as possible.
4. The less use of root privileges the better. Services should run as "researcher" when possible.


