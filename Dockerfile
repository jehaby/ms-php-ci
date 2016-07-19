FROM php:fpm

RUN apt-get update \
    && apt-get -y install \
       	    git \
            libmagickwand-dev \
            libpq-dev \
            libxml2-dev \
        --no-install-recommends \
    && pecl install \
             apcu \
             imagick \
    && docker-php-ext-enable \
             apcu \
             imagick \
    && docker-php-ext-install \
            dom \
            pdo_pgsql \
            xml \
            zip \
    && rm -r /var/lib/apt/lists/*

# Composer
RUN curl -o /tmp/composer-setup.php https://getcomposer.org/installer \
  && curl -o /tmp/composer-setup.sig https://composer.github.io/installer.sig \
  && php -r "if (hash('SHA384', file_get_contents('/tmp/composer-setup.php')) !== trim(file_get_contents('/tmp/composer-setup.sig'))) { unlink('/tmp/composer-setup.php'); echo 'Invalid installer' . PHP_EOL; exit(1); }" \
  && php /tmp/composer-setup.php \
  && mv composer.phar /usr/bin/composer \
  && chmod a+x /usr/bin/composer

RUN adduser --disabled-password --gecos "" --uid 1000 user-from-host

ENV PHPREDIS_VERSION=3.0.0
RUN cd /usr/src/php/ext \
    && curl -q https://codeload.github.com/phpredis/phpredis/tar.gz/$PHPREDIS_VERSION | tar -xz \
    && docker-php-ext-install phpredis-$PHPREDIS_VERSION

USER user-from-host
WORKDIR /var/www
