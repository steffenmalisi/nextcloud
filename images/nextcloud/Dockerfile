# Builder image to compile php extensions
# Only adds dependecies required for building those extensions
# Typically, those dependencies are not required for running Nextcloud, so we use a multi-stage build to keep the final image small.
FROM nextcloud:34.0.5-fpm AS builder

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libbz2-dev

RUN docker-php-ext-install bz2


# Final image
# Only installs the dependencies required for running Nextcloud, and copies the compiled extensions from the builder image.
FROM nextcloud:34.0.5-fpm

COPY --from=builder /usr/local/lib/php/extensions /usr/local/lib/php/extensions

RUN set -ex; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ffmpeg \    
        libimage-exiftool-perl \
        netcat-openbsd \
        supervisor \
    ; \
    rm -rf /var/lib/apt/lists/*


RUN mkdir /var/log/supervisord /var/run/supervisord \
  ; \
  mkdir /mnt/ncdata \
    && chown www-data:www-data /mnt/ncdata \
  ; \
  echo '*/30 *  *  *  * php -f /var/www/html/occ face:background_job -t 900' >> /var/spool/cron/crontabs/www-data; \
  echo '*/10 *  *  *  * php -f /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data \
  ; \
  echo "extension=bz2.so" > /usr/local/etc/php/conf.d/bz2.ini


COPY *.sh supervisord.conf /

ENV NEXTCLOUD_UPDATE=1

ENTRYPOINT [ "/start.sh" ]

CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]