FROM nextcloud:27.1.3-fpm AS builder
# libx11-dev has to be installed before dlib
RUN apt-get update && apt-get install -y cmake git libx11-dev
RUN git clone https://github.com/davisking/dlib.git \
  && cd dlib/dlib \
  && mkdir build \
  && cd build \
  && cmake -DBUILD_SHARED_LIBS=ON .. \
  && make \
  && make install
RUN apt-get install -y libopenblas-dev ffmpeg
RUN git clone https://github.com/goodspb/pdlib.git \
  && cd pdlib \
  && phpize \
  && ./configure --enable-debug \
  && make \
  && make install
RUN echo "extension=pdlib.so" > /usr/local/etc/php/conf.d/pdlib.ini
RUN apt-get install -y libbz2-dev
RUN docker-php-ext-install bz2
RUN apt-get install -y wget
RUN git clone https://github.com/matiasdelellis/pdlib-min-test-suite.git \
    && cd pdlib-min-test-suite \
    && make

FROM nextcloud:27.1.3-fpm
RUN apt-get update && apt-get install -y \
    supervisor \
    ffmpeg \
    netcat-openbsd \
  && rm -rf /var/lib/apt/lists/* \
  ; \
  mkdir /var/log/supervisord /var/run/supervisord \
  ; \
  mkdir /mnt/ncdata \
    && chown www-data:www-data /mnt/ncdata \
  ; \
  echo '*/30 *  *  *  * php -f /var/www/html/occ face:background_job -t 900' >> /var/spool/cron/crontabs/www-data; \
  echo '*/10 *  *  *  * php -f /var/www/html/occ preview:pre-generate' >> /var/spool/cron/crontabs/www-data \
  ; \
  echo "extension=pdlib.so" > /usr/local/etc/php/conf.d/pdlib.ini; \
  echo "extension=bz2.so" > /usr/local/etc/php/conf.d/bz2.ini
COPY --from=builder /usr/local/lib/libdlib.so* /usr/local/lib
COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20220829 /usr/local/lib/php/extensions/no-debug-non-zts-20220829
COPY *.sh supervisord.conf /
ENV NEXTCLOUD_UPDATE=1
ENTRYPOINT [ "/start.sh" ]
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]