#!/bin/sh

get_php_pid() {
    echo $(ps | grep "start-php-fpm" -m1 | grep -v grep | sed 's/^[ \t]*//;s/[ \t]*$//' | cut -d " " -f1)
}

echo "Waiting for php container process to be available in processlist..."

while [ -z "$(get_php_pid)" ]; do sleep 1; done

echo "Found php container process PID: $(get_php_pid)"

ln -s /proc/$(ps | grep "start-php-fpm" -m1 | grep -v grep | sed 's/^[ \t]*//;s/[ \t]*$//' | cut -d " " -f1)/root/app/web $DOCUMENT_ROOT

echo "Linked cross-process webroot"




/usr/bin/openresty -g 'daemon off;' -c /usr/local/docker/etc/nginx/nginx.conf