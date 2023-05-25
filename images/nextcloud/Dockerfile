FROM nextcloud:26.0.1-fpm

# see https://github.com/nextcloud/docker/blob/master/.examples/dockerfiles/cron/fpm/Dockerfile
# see https://github.com/matiasdelellis/facerecognition/wiki/Docker

RUN apt-get update && apt-get install -y \
    supervisor \
    ffmpeg \
    wget \
    gnupg2 \
    unzip \
    libbz2-dev \
    netcat \
  && rm -rf /var/lib/apt/lists/* \
  ; \
  mkdir /var/log/supervisord /var/run/supervisord; \
  mkdir /mnt/ncdata && chown www-data:www-data /mnt/ncdata; \
  echo '*/30 *  *  *  * php -f /var/www/html/occ face:background_job -t 900' >> /var/spool/cron/crontabs/www-data; \
  echo '*/10 *  *  *  * php -f /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data

# Enable repo and install dlib
RUN echo "deb https://repo.delellis.com.ar bullseye bullseye" > /etc/apt/sources.list.d/20-pdlib.list \
  && wget -qO - https://repo.delellis.com.ar/repo.gpg.key | apt-key add -
RUN apt update \
  && apt install -y libdlib-dev

# Install pdlib extension
RUN wget https://github.com/goodspb/pdlib/archive/master.zip \
  && mkdir -p /usr/src/php/ext/ \
  && unzip -d /usr/src/php/ext/ master.zip \
  && rm master.zip

# Install php extensions needed for facerecognition
RUN docker-php-ext-install \
  pdlib-master \
  bz2 \
  ;

# Increase memory limits
RUN echo memory_limit=1024M > /usr/local/etc/php/conf.d/memory-limit.ini

COPY *.sh supervisord.conf /

ENV NEXTCLOUD_UPDATE=1

ENTRYPOINT [ "/start.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]