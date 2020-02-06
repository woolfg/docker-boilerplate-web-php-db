FROM mariadb:10

COPY my.cnf /etc/mysql/conf.d/my.cnf
COPY init_import.sql.gz /docker-entrypoint-initdb.d/init.sql.gz