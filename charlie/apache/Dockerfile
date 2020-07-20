FROM debian:8.11

LABEL maintainer="Leszek Rączka <leszek@asdzxcv.com>"

COPY ./temp /docker_temp/apache
COPY ./startup_configuration /startup_configuration

RUN apt-get update && \
	apt-get -y install \
		nano \
		curl \
		wget && \
	curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
	apt-get -y install \
		nodejs \
		php5 \
		php5-xdebug \
		php5-mysql \
		php5-curl \
		openssl \
		gem \
		git \
		unzip \
		supervisor \
		bash-completion \
		acl \
		sudo && \
	# Composer
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('sha384', 'composer-setup.php') === 'e5325b19b381bfd88ce90a5ddb7823406b2a38cff6bb704b0acc289a09c8128d4a8ce2bbafcd1fcbdc38666422fe2806') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
	# PhpMyAdmin
	export VER="4.9.0.1" && \
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
	cp /docker_temp/apache/apache_php.ini /etc/php5/apache2/php.ini && \
	cp /docker_temp/apache/cli_php.ini /etc/php5/cli/php.ini && \
	cp /docker_temp/apache/xdebug.ini /etc/php5/mods-available/ && \
	# Prepare user
	adduser momo && \
	usermod -aG www-data,sudo momo && \
	usermod -p $(openssl passwd asd) momo && \
	mkdir /srv/www && \
	chmod g+s /srv/www && \
	chown www-data:momo /srv/www && \
	setfacl -d -m g::rwx /srv/www && \
	setfacl -d -m o::rx /srv/www;
	
RUN ["/bin/bash", "-c", "source /etc/bash_completion"]

CMD ["/startup_configuration/run.sh"]
