#!/bin/bash

[ ! -f "${HORIZON_BASEDIR}/openstack_dashboard/local/local_settings.py" ] && echo "Error: local_settings.py not mounted!" && exit 1
[ ! -f "${HORIZON_BASEDIR}/certs/hostcert.pem" ] && echo "Error: Hostcert not mounted!" && exit 1
[ ! -f "${HORIZON_BASEDIR}/certs/hostkey.pem" ] && echo "Error: Hostkey not mounted!" && exit 1
[ ! -d "${HORIZON_BASEDIR}/policy" ] && echo "Warn: policy not mounted!" && exit 1

./manage.py collectstatic --noinput
./manage.py compress --force
./manage.py make_web_conf --wsgi
rm -rf /etc/apache2/sites-enabled/*
./manage.py make_web_conf --apache --ssl --sslkey=${HORIZON_BASEDIR}/certs/hostkey.pem --sslcert=${HORIZON_BASEDIR}/certs/hostcert.pem > /etc/apache2/sites-enabled/horizon.conf
sed -i 's/<VirtualHost \*.*/<VirtualHost _default_:443>/g' /etc/apache2/sites-enabled/horizon.conf
python -m compileall $HORIZON_BASEDIR
ln -s ${HORIZON_BASEDIR}/openstack_dashboard /var/www/html/
ln -s ${HORIZON_BASEDIR}/horizon/static /var/www/html/static
ln -s ${HORIZON_BASEDIR}/media /var/www/html/media
chown -R www-data:www-data ${HORIZON_BASEDIR}
chown -R www-data:www-data /var/www/html
sed -i "/LogLevel/c\    LogLevel ${APACHE_LOGLEVEL}" /etc/apache2/sites-enabled/horizon.conf
sed -i "/ErrorLog/c\    ErrorLog \/dev\/stderr" /etc/apache2/sites-enabled/horizon.conf
sed -i "/CustomLog/c\    CustomLog \/dev\/stdout combined" /etc/apache2/sites-enabled/horizon.conf
sed -i "/ErrorLog/c\    ErrorLog \/dev\/stderr" /etc/apache2/apache2.conf

apachectl -DFOREGROUND
