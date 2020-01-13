FROM nginx:stable-alpine

COPY web/nginx.conf /etc/nginx/conf.d/default.conf
COPY web/init_volume.sh /init_volume.sh
COPY src /www_init