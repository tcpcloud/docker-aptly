FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

# Install aptly and required tools
RUN apt-get -q update \
    && apt-get -y --no-install-recommends install python-pip python-apt python-requests python-yaml python-setuptools python-wheel \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install python-aptly

WORKDIR /var/run/aptly-publisher
ENTRYPOINT ["aptly-publisher"]
