FROM php:5.6-apache

RUN a2enmod rewrite

RUN apt-get update && apt-get install -y nodejs npm git libpng12-dev libjpeg-dev libpq-dev libmcrypt-dev libcurl4-gnutls-dev && \
    docker-php-ext-configure gd --with-png-dir=/usr --with-jpeg-dir=/usr  && \
    docker-php-ext-install gd mysqli mcrypt pdo pdo_mysql curl fileinfo

RUN echo 'allow_url_fopen = 1' >> /usr/local/etc/php/conf.d/directus.ini && \
    echo 'always_populate_raw_post_data = -1' >> /usr/local/etc/php/conf.d/directus.ini

WORKDIR /var/www/html

ENV DIRECTUS_VERSION 6.3.4
ENV DIRECTUS_MD5_SUM 5ff2b5f1edb35eb835f73211e1f485e0

RUN curl -fSL "https://github.com/directus/directus/archive/${DIRECTUS_VERSION}.tar.gz" -o directus.tar.gz && \
    echo "${DIRECTUS_MD5_SUM} *directus.tar.gz" | md5sum -c - && \
    tar -xz --strip=1 -f directus.tar.gz && \
    rm directus.tar.gz && \
    touch api/config.php && \
    chown -R www-data.www-data ./

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === 'aa96f26c2b67226a324c27919f1eb05f21c248b987e6195cad9690d5c1ff713d53020a02ac8c217dbf90a7eacc9d141d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');" && \
    chmod a+x /usr/local/bin/composer && \
    composer install

RUN npm install -g npm && \
    npm install -g n && \
    n stable && \
    npm install -g gulp && \
    npm install && \
    gulp build
