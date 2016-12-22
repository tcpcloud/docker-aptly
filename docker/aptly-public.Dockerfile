FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update \
    && apt-get install -y nginx

COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/aptly-site.conf /etc/nginx/sites-available/default

EXPOSE 80
ENTRYPOINT ["/usr/sbin/nginx"]
