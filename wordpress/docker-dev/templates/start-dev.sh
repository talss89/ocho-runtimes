#! /bin/sh

get_php_pid() {
    echo $(ps ax | grep "start-dev" -m1 | grep -v grep | sed 's/^[ \t]*//;s/[ \t]*$//' | cut -d " " -f1)
}

cp /usr/local/docker/etc/.bashrc ~/.bashrc

rm -f /srv/web
ln -s /proc/$(get_php_pid)/root$DOCUMENT_ROOT /srv/web

if [ -f "composer.json" ]; then
   echo "Installing PHP dependencies"
   composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --prefer-dist
fi

if [ -f "yarn.lock" ]; then
   echo "Installing Yarn Dependencies"
   yarn
else 
   if [ -f "package.json" ]; then
      echo "Installing NPM Dependencies"
      npm install
   fi
fi

/usr/local/sbin/php-fpm -y /usr/local/docker/etc/php-fpm.conf &

wait

sleep 0.2
