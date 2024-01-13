#! /bin/sh

get_php_pid() {
    echo $(ps ax | grep "start-php-fpm" -m1 | grep -v grep | sed 's/^[ \t]*//;s/[ \t]*$//' | cut -d " " -f1)
}

rm -f /srv/web
ln -s /proc/$(get_php_pid)/root$DOCUMENT_ROOT /srv/web

/usr/local/sbin/php-fpm -y /usr/local/docker/etc/php-fpm.conf &

wait

sleep 0.2
