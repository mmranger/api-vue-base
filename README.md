# Readme

## Start

### Build this project

* clone the project
* change the directory (api-vue-base) name to your project name
* remove .git directory so can init and add to your repo
* ```make docker-build```

## Vue (front) located on port 80

### Create the vue app

* ```vue create front``` ## Was used to create
* Use make docker-run-npm CMD='[SOME COMMAND]' to install whatever else you need for vue or npm
<!-- * ```make docker-run-yarn CMD='serve'``` ## Fire up the server (reuse this each time after docker changes and come back up) -->
* edit files under ./front as needed
* [@vue/cli documentation](https://cli.vuejs.org/guide/) for more
* Specifically [documentation on directives](https://012.vuejs.org/guide/directives.html)
* Should install vue devtools follow directions on the [github](https://github.com/vuejs/vue-devtools)

### Adding bootstrap vue

* ```make docker-run-npm CMD='i bootstrap-vue bootstrap'``` ## Install bootstrap for vue
* See [bootstrap docs](https://bootstrap-vue.js.org/docs) for more

### Create Production Build
 
* npm run build

## Symfony (backend api) located on port 8000

### Create the symfony api

* ```create-project symfony/skeleton api``` ## was used to create
* edit the files under ./api and use the make docker-run-composer command to add to symfony with composer as needed
* [symfony documentation](https://symfony.com/doc/current/index.html#gsc.tab=0) for more

## More Troubleshooting

### To update configs for postgres

* ```make docker-down``` (unfortunately kills everything)
* ```rm -r .docker/db/data/``` ## removing mounted data directory
* add config file in .docker/db/config
* edit .docker/db/docker-entrypoint-initdb.d/update_pg_hba.sh
* add line /var/lib/postgresql/configs/<new config>.conf /var/lib/postgresql/data/<new config>.conf
* ```make docker-up``` ## can be run to just CONTAINER='db'

## Postgres db issues

* ```docker restart <container_id>``` ## to restart postgres container - lookup id with docker ps
* ```make docker-db CMD='chown -R postgres:postgres /var/lib/postgresql/data'``` to return ownership to postgres of all data, then restart as above

## Symfony route check

* ```make docker-run-console CMD='debug:router'```

## update db structure

* php bin/console make:entity ```make docker-run-console CMD='make:entity'```
* php bin/console make:migration  ```make docker-run-console CMD='make:migration'```
* php bin/console doctrine:migrations:migrate ```make docker-run-console CMD='doctrine:migrations:migrate'```
