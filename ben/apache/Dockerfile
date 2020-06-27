FROM debian:10.1

LABEL maintainer="Leszek Rączka <leszek@asdzxcv.com>"

COPY ./temp /docker_temp/apache
COPY ./startup_configuration /startup_configuration

RUN apt-get update && \
	apt-get -y install \
		nano \
		curl \
		wget \
		nodejs \
		npm \
		php \
		php-dev \
		php-xdebug \
		php-mysql \
		supervisor \
		gem \
		git \
		unzip \
		composer \
		php-pear \
		sudo \
		bash-completion
RUN ["/bin/bash", "-c", "source /etc/bash_completion"]
# PhpMyAdmin
RUN export VER="4.9.0.1" && \
	wget https://files.phpmyadmin.net/phpMyAdmin/${VER}/phpMyAdmin-${VER}-all-languages.tar.gz && \
	tar xvf phpMyAdmin-${VER}-all-languages.tar.gz && \
	rm phpMyAdmin*.gz && \
	mv phpMyAdmin-* /usr/share/phpmyadmin && \
	mkdir -p /var/lib/phpmyadmin/tmp && \
	chown -R www-data:www-data /var/lib/phpmyadmin && \
	mkdir /etc/phpmyadmin/ && \
	cp /usr/share/phpmyadmin/config.sample.inc.php  /usr/share/phpmyadmin/config.inc.php && \
	cp /docker_temp/apache/phpmyadmin.conf /etc/apache2/sites-available && \
	a2ensite phpmyadmin && \
	sed -i -e "s/\$cfg\['blowfish_secret'\] = ''/\$cfg\['blowfish_secret'\] = '`date | md5sum`'/" \
		/usr/share/phpmyadmin/config.inc.php && \
	sed -i -e "s/\$cfg\['Servers'\]\[\$i\]\['host'\] = .*/\$cfg\['Servers'\]\[\$i\]\['host'\] = 'mysql';/" \
		/usr/share/phpmyadmin/config.inc.php && \
	echo "\$cfg['TempDir'] = '/var/lib/phpmyadmin/tmp';" >> /usr/share/phpmyadmin/config.inc.php && \
	# SSL configuration
	openssl genrsa -des3 -passout pass:test_pass -out server.pass.key 2048 && \
	openssl rsa -passin pass:test_pass -in server.pass.key -out server.key && \
	rm server.pass.key && \
	openssl req -new -key server.key -out server.csr \
		-subj "/C=UK/ST=Warwickshire/L=Leamington/O=OrgName/OU=IT Department/CN=*" && \
	openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt && \
	mkdir /etc/apache2/ssl && \
	mv server.crt server.key server.csr /etc/apache2/ssl/ && \
	# Other PHP stuff
	a2enmod ssl && \
	a2enmod headers && \
	a2enmod rewrite && \
	cp /docker_temp/apache/apache_php.ini /etc/php/7.3/apache2/php.ini && \
	cp /docker_temp/apache/cli_php.ini /etc/php/7.3/cli/php.ini && \
	cp /docker_temp/apache/xdebug.ini /etc/php/7.3/mods-available/ && \
	# Prepare user
	adduser momo && \
	usermod -aG www-data momo && \
	usermod -p $(openssl passwd asd) momo && \
	pecl install xdebug;

CMD ["/startup_configuration/run.sh"]
