FROM debian:sid

ENV DEBIAN_FRONTEND noninteractive

# Install aptly and required tools
RUN apt-get -q update                     \
    && apt-get -y install aptly-publisher

WORKDIR /var/run/aptly-publisher
ENTRYPOINT ["aptly-publisher"]
