#!/bin/sh

rm -f $DOCUMENT_ROOT
ln -s /srv/web $DOCUMENT_ROOT

/usr/bin/openresty -g 'daemon off;' -c /usr/local/docker/etc/nginx/nginx.conf