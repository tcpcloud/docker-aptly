FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update \
    && apt-get install -y nginx

RUN echo "daemon off;" >>/etc/nginx/nginx.conf

EXPOSE 80
ENTRYPOINT ["/usr/sbin/nginx"]
