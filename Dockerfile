FROM php:7.3-apache-stretch

#setup env variables
ENV APP_NAME=$APP_NAME \
    APP_ENV=production \
    APP_KEY=$APP_KEY \
    APP_DEBUG=false \
    APP_URL=$APP_URL \
    LOG_CHANNEL=stack \
    DB_CONNECTION=$DB_CONNECTION \
    DB_HOST=$DB_HOST \
    DB_PORT=$DB_PORT \
    DB_DATABASE=$DB_DATABASE \
    DB_USERNAME=$DB_USERNAME \
    DB_PASSWORD=$DB_PASSWORD \
    BROADCAST_DRIVER=log \
    CACHE_DRIVER=file \
    QUEUE_CONNECTION=sync \
    SESSION_DRIVER=file \
    SESSION_LIFETIME=120 \
    REDIS_HOST=$REDIS_HOST \
    REDIS_PASSWORD=$REDIS_PASSWORD \
    REDIS_PORT=$REDIS_PORT \
    MAIL_MAILER=smtp \
    MAIL_HOST=$MAIL_HOST \
    MAIL_PORT=$MAIL_PORT \
    MAIL_USERNAME=$MAIL_USERNAME \
    MAIL_PASSWORD=$MAIL_PASSWORD \
    MAIL_ENCRYPTION=$MAIL_ENCRYPTION \
    MAIL_FROM_ADDRESS=$MAIL_FROM \
    MAIL_FROM_NAME=$MAIL_FROM_NAME \

#Install depencencies

RUN apt-get update -y && \
    apt-get install unzip git curl gnupg libzip-dev libonig-dev libicu-dev cron supervisor libxml2-dev apt-transport-https -yq && \
    a2enmod rewrite && \
    a2enmod expires && \
    pecl install redis && \
    docker-php-ext-enable redis && \
    docker-php-ext-install mbstring intl zip pdo_mysql bcmath pcntl soap && \
    docker-php-ext-configure zip && \
    docker-php-ext-configure intl && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&  \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash && \
    apt-get update -y && \
    apt-get install nodejs yarn -yq && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    apt-get clean

#copy all files to app folder
WORKDIR /var/www/html
COPY --chown=www-data:www-data . /var/www/html

#Install composer
RUN composer install --prefer-dist --no-dev --no-scripts --no-progress

#Install npm for building frontend and build frontend
RUN yarn install && \
    npm run production

# Add crontab file in the cron directory
RUN (crontab -l ; echo "* * * * * su -c 'php /var/www/html/artisan schedule:run >> /var/www/html/storage/log/schedule.log 2>&1'"   ) | crontab

#Fix permissions
RUN mkdir -p /var/log/supervisor && chmod -R ug+rwx /var/www/html/storage && chmod +x /var/www/html/start.sh && chown -R www-data:www-data /var/www/html/vendor

EXPOSE 80

CMD ["/var/www/html/start.sh"]

