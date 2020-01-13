server {
    index index.php index.html;
    server_name ${PROJECT_HOSTNAMES};
    root /www;

    # works for most php setups, e.g. wordpress
    if (!-e $request_filename) { 
      rewrite ^(.+)$ /index.php?q=$1 last; 
    } 

    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
}