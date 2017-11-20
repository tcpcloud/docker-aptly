FROM debian:sid

ENV DEBIAN_FRONTEND noninteractive

# Install aptly and required tools
RUN apt-get -q update \
    && apt-get -y install python-pip python-requests python-yaml \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN pip install python-aptly

WORKDIR /var/run/aptly-publisher
ENTRYPOINT ["aptly-publisher"]
