#!/bin/bash
#php artisan telescope:publish
php artisan config:cache
php artisan event:cache
php artisan view:clear
php artisan migrate --force

service cron start

supervisord -n -c /var/www/html/supervisor.conf
