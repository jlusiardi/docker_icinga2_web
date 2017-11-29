# docker_icinga2_web

## Requirements

 * access to icinga core api
 * access to icinga ido database
 * access to database for authentication data
 
## Start

Make sure database for authentication data exists:
```
docker run -d \
           --name icinga_auth_db \
           -e MYSQL_ROOT_PASSWORD=$ROOT_PWD \ 
           -e MYSQL_USER=icinga \ 
           -e MYSQL_PASSWORD=icinga \ 
           -e MYSQL_DATABASE=icinga \ 
           -v $DIR_ON_HOST:/var/lib/mysql \
           mysql:5.7
```

Initialize the authentication db on first run:
```
docker run --rm \
           -ti \ 
           --link icinga_auth_db:mysql_auth \
           docker_icinga2_web init
```

Run container:
```
docker run --name icingaweb2 \ 
           -d \
           --link icinga_auth_db:mysql_auth \
           --link icinga_db:mysql_ido \
           --link icinga:icinga_core \
           -p 8181:80 \ 
           docker_icinga2_web 
```

## Notes
The file **icinga.key** was taken from http://packages.icinga.com/icinga.key.