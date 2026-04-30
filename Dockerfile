FROM php:7.4-apache

# Fix Debian archive sources (required for old images)
RUN printf "deb http://archive.debian.org/debian bullseye main contrib non-free\n" > /etc/apt/sources.list && \
    printf 'Acquire::Check-Valid-Until "false";\nAcquire::AllowInsecureRepositories "true";\n' > /etc/apt/apt.conf.d/99archive && \
    apt-get update

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
