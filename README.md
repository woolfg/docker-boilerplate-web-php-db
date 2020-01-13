# Boilderplate Docker PHP+MySQL

This boilerplate project can be used for running legacy php projects with Mysql in a docker environment such as swarm. 

## Migration Procedure

- adapt values in CONFIG file for your project
- `make dumpdb-legacy` to download a dump of the current legacy prod db
- `make dumpcode-legacy` dump code of the legacy server
- copy the db dump to `db/init_import.sql`
- copy source code to `./src`
- adapt config files of the project code and change db access data to new setup
- `make run` starts a local stack which should already work everything, you can access the project at `localhost` in your browser
- if there are any problems, try to fix them until everything works fine or perform updates when needed
- if everything works fine you can dump the local db again to be up to date for the prod version (use `make dumpdb` and copy file to init_import.sql)