===================
Docker Aptly images
===================

This repository contains Docker images for Aptly components and tools.

- aptly-api

  - Container running ``aptly api serve``

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

    docker run -it -v /srv/aptly:/var/lib/aptly tcpcloud/aptly-api

Run aptly action, eg. list repos:

.. code-block:: bash

    docker run -it -v /srv/aptly:/var/lib/aptly tcpcloud/aptly-api aptly repo list
