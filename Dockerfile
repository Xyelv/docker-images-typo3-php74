FROM php:7.4-apache

# Fix Debian archive sources (required for old images)
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list && \
    sed -i 's|security.debian.org/debian-security|archive.debian.org/debian-security|g' /etc/apt/sources.list && \
    apt-get -o Acquire::Check-Valid-Until=false update

# Install system packages (fixed names)
RUN apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    zip \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# PHP Extensions
RUN docker-php-ext-configure gd \
  --with-freetype-dir=/usr/include/freetype2 \
  --with-jpeg-dir=/usr/include

RUN docker-php-ext-install -j$(nproc) \
    gd \
    mysqli \
    pdo_mysql \
    zip \
    intl \
    xml \
    mbstring \
    opcache \
    soap \
    json

# Apache modules
RUN a2enmod rewrite headers expires

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# TYPO3 config
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/sites-available/*.conf && \
    sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' \
    /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

WORKDIR /var/www/html

EXPOSE 80
