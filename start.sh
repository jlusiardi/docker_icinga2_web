#!/bin/bash 

MODE=$1

if [ "$MODE" == "init" ]; then
    echo "**********************"
    echo "*    preparing...    *"
    echo "**********************"
    apt install -y -q mysql-client
    DB_UTIL="mysql -u root -p$MYSQL_AUTH_ENV_MYSQL_ROOT_PASSWORD -h mysql_auth $MYSQL_AUTH_ENV_MYSQL_DATABASE"
    echo "*************************"
    echo "*    initializing...    *"
    echo "*************************"
    ${DB_UTIL}  < /usr/share/icingaweb2/etc/schema/mysql.schema.sql
    read -s -p "Password for user 'icinga': " PASSWORD
    echo
    HASH=`openssl passwd -1 ${PASSWORD}`
    echo "INSERT INTO icingaweb_user (name, active, password_hash) VALUES ('icinga', 1, '$HASH');" | ${DB_UTIL}
    echo "Now start normal..."
else
    chown -R www-data /etc/icingaweb2
    for VAR in `env | sed 's/=.*//'`
    do
	    sed -i "s|__${VAR}__|${!VAR}|" /etc/icingaweb2/resources.ini;
	    sed -i "s|__${VAR}__|${!VAR}|" /etc/icingaweb2/modules/monitoring/commandtransports.ini
    done

    source /etc/apache2/envvars
    ln -sf /dev/stdout  /var/log/apache2/access.log
    ln -sf /dev/stderr /var/log/apache2/error.log

    # remove stale pid file if exists
    rm -f /run/apache2/apache2.pid

    apache2 -DFOREGROUND -f /etc/apache2/apache2.conf
fi
