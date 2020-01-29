server {
    index index.php index.html;
    server_name ${PROJECT_HOSTNAMES};
    root /www;

    # works for most php setups, e.g. wordpress
    location / {
      try_files $uri $uri/ /index.php?$args;
    }

    location ~ \.php$ {

        # define the docker dns resolver
        resolver 127.0.0.11;
        set $upstream ${PROJECT}_php:9000;
        
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass $upstream;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}