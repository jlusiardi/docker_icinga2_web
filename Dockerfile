FROM debian:buster

ENV DEBIAN_FRONTEND noninteractive

ADD icinga.key /tmp/icinga.key

RUN apt-get update -y; \
    apt-get install -y gnupg2; \ 
    apt-key add /tmp/icinga.key; \
    echo 'deb http://packages.icinga.com/debian icinga-buster main' > /etc/apt/sources.list.d/icinga.list; \
    apt-get update -y; \
    apt-get install -y icingaweb2; 

#RUN echo "date.timezone = \"Europe/Berlin\"" >> /etc/php5/apache2/php.ini

#RUN apt-get install -y php5-imagick php5-intl php5-curl

RUN usermod -a -G icingaweb2 www-data; \
    icingacli setup config directory --group icingaweb2; \
    icingacli setup token create > /token;

ADD start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

ADD icingaweb2 /etc/icingaweb2

EXPOSE 80

ENTRYPOINT ["/opt/start.sh"]
CMD ["normal"]
