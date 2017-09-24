FROM netsyos/nginx:latest

RUN add-apt-repository -y ppa:ondrej/php

RUN apt-get update

RUN apt-get -y --force-yes install php7.1-cli php7.1-fpm php7.1-mysql php7.1-json php7.1-mcrypt \
     php7.1-curl php7.1-xml php7.1-gd php7.1-intl php7.1-imap \
     php7.1-dev php7.1-bcmath php7.1-bz2 php7.1-mbstring php7.1-soap \
     php7.1-zip php7.1-imagick php-ssh2

RUN apt-get install -y \
  rsync \
  bzip2 \
  libcurl4-openssl-dev \
  libfreetype6-dev \
  libicu-dev \
  libjpeg-dev \
  libldap2-dev \
  libmcrypt-dev \
  libmemcached-dev \
  libpng12-dev \
  libpq-dev \
  libxml2-dev

RUN apt-get install -y \
  pkg-config

# PECL extensions
RUN set -ex \
 && pecl install APCu-5.1.8 \
 && pecl install memcached-3.0.3 \
 && pecl install redis-3.1.3
#  \
# && docker-php-ext-enable apcu redis memcached

ENV WWW_PATH /var/www

COPY config/php/php.ini /etc/php/7.1/fpm/
COPY config/php/php.ini /etc/php/7.1/cli/
COPY config/nginx/nginx.conf /etc/nginx/
RUN echo "extension = apcu.so" | tee -a /etc/php/7.1/mods-available/apcu.ini
RUN ln -s /etc/php/7.1/mods-available/apcu.ini /etc/php/7.1/fpm/conf.d/30-apcu.ini
RUN ln -s /etc/php/7.1/mods-available/apcu.ini /etc/php/7.1/cli/conf.d/30-apcu.ini

RUN chown -R www-data:www-data $WWW_PATH/
RUN rm -rf $WWW_PATH/*

RUN mkdir /run/php
RUN mkdir /etc/service/fpm
ADD service/fpm.sh /etc/service/fpm/run
RUN chmod +x /etc/service/fpm/run

RUN mkdir /etc/service/logs
ADD service/logs.sh /etc/service/logs/run
RUN chmod +x /etc/service/logs/run

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*