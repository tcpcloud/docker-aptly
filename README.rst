===================
Docker Aptly images
===================

This repository contains Docker images for Aptly components and tools.

- aptly

  - Container with aptly tooling

- aptly-api

  - Container running ``aptly api serve``

- aptly-public

  - Container running nginx and serving aptly's public directory

- aptly-publisher

  - Container with ``aptly-publisher`` tool for management of Aptly publishes,
    requires running aptly-api

aptly-api
=========

Environment variables
---------------------

- **USER_ID** - UID of aptly user (default 501)
- **FULL_NAME** - Full name for GPG key generation (if it doesn't already
  exist)
- **EMAIL_ADDRESS** - Email address for GPG key generation

Usage
-----

To have persistant Aptly instance, you need to use persistent volume.
Recommended way is to bind-mount it into ``/var/lib/aptly``.

Run aptly API:

.. code-block:: bash

    docker run -v /srv/aptly:/var/lib/aptly tcpcloud/aptly-api

Run aptly action, eg. list repos:

.. code-block:: bash

    docker run -it -v /srv/aptly:/var/lib/aptly tcpcloud/aptly-api aptly repo list

aptly-public
============

To be able to provide access to repository, you can use ``aptly-web`` image
which will run Nginx to serve aptly's public directory.

Usage
-----

Simply bind-mount public directory on your aptly volume as ``/var/www/html``,
eg.:

.. code-block:: bash

    docker run -v /srv/aptly/public:/var/www:ro tcpcloud/aptly-public

aptly-publisher
===============

Usage
-----

You can use aptly-publisher in a similar way as if it's installed on your
system.

Run using docker:

.. code-block:: bash

    docker run -it tcpcloud/aptly-publisher --help

Or create ``/usr/local/bin/aptly-publisher`` with following:

.. code-block:: bash

    #!/bin/bash -e

    docker run -v $(pwd):/var/run/aptly-publisher:ro -it tcpcloud/aptly-publisher $@

and set exec permissions with ``chmod +x /usr/local/bin/aptly-publisher``.
Then you are able to use config file in your current directory.
