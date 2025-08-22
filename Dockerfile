FROM php:8.1-apache

# Enable Apache modules
RUN a2enmod rewrite

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql

# Configure PHP for performance
RUN echo 'memory_limit = 256M' >> /usr/local/etc/php/conf.d/performance.ini && \
    echo 'max_execution_time = 30' >> /usr/local/etc/php/conf.d/performance.ini && \
    echo 'opcache.enable=1' >> /usr/local/etc/php/conf.d/performance.ini && \
    echo 'opcache.memory_consumption=128' >> /usr/local/etc/php/conf.d/performance.ini

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY app/ /var/www/html/

# Set permissions
RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 80