FROM nginx:stable-alpine

# remove default logging to add json logging in nginx.conf of project
RUN sed -i "s/access_log.*main;//" /etc/nginx/nginx.conf

COPY web/nginx.conf /etc/nginx/conf.d/default.conf

