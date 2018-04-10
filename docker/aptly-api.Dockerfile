FROM mirantis/aptly

VOLUME ["/var/lib/aptly"]
EXPOSE 8080

CMD ["aptly", "api", "serve", "-no-lock"]
