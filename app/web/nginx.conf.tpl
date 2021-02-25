map $http_x_request_id $current_request_id {
  default   "${request_id}";
  ~*        "${http_x_request_id}";
}


log_format combined_json escape=json
'{'
  '"time_local":"$time_local",'
  '"remote_addr":"$remote_addr",'
  '"remote_user":"$remote_user",'
  '"request":"$request",'
  '"status": "$status",'
  '"body_bytes_sent":"$body_bytes_sent",'
  '"request_time":"$request_time",'
  '"http_referrer":"$http_referer",'
  '"http_user_agent":"$http_user_agent",'
  '"http_x_forwarded_for":"$http_x_forwarded_for",'
  '"http_x_request_id":"$current_request_id"'
'}';  

access_log  /var/log/nginx/access.log combined_json;

server {
    index index.php index.html;
    server_name ${PROJECT_HOSTNAMES};
    root /www;

    # works for most php setups, e.g. wordpress
    location / {
      try_files $uri $uri/ /index.php?$args;
    }
    add_header X-Request-ID $current_request_id;       

    location ~ \.php$ {

        # define the docker dns resolver
        resolver 127.0.0.11;
        set $upstream ${PROJECT}_php:9000;
        
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass $upstream;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param HTTP_X_REQUEST_ID $current_request_id;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}