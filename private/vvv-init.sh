#!/bin/bash

set -e

cd ..
printf "Setting up: %s\n" $(basename $(pwd))

if [ $( php -r "echo class_exists( 'Redis' ) ? 1 : 0;" ) == "0" ]; then
	(
	cd /tmp
	apt-get install -y redis-server php5-dev
	if [ -e phpredis ]; then
		cd phpredis
		git pull
	else
		git clone https://github.com/nicolasff/phpredis.git
		cd phpredis
	fi
	phpize
	./configure
	make && make install
	echo "extension=redis.so" > /etc/php5/fpm/conf.d/20-redis.ini
	cp /etc/php5/fpm/conf.d/20-redis.ini /etc/php5/cli/conf.d/20-redis.ini
	service php5-fpm restart
	)
fi

if [ ! -e wp-config-local.php ]; then
	echo -e '<?php \n/* You can define any overrides you want right here. */\nrequire_once "private/wp-config-vvv.php";' > wp-config-local.php
fi

# Export required PHP constants into Bash.
eval $(php -r '
	require_once( "wp-config-local.php" );
	foreach( explode( " ", "DB_NAME DB_HOST DB_USER DB_PASSWORD DB_CHARSET" ) as $key ) {
		echo $key . "=" . constant( $key ) . PHP_EOL;
	}
')

# Make a database, if we don't already have one.
mysql -u root --password=root -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET $DB_CHARSET"
mysql -u root --password=root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO $DB_USER@localhost IDENTIFIED BY '$DB_PASSWORD';"

db_populated=`mysql -u root -proot --skip-column-names -e "SHOW TABLES FROM $DB_NAME"`
if [ "" == "$db_populated" ] && [ -e private/vvv.sql ]; then
	echo "Loading vvv.sql"
	mysql -u $DB_USER -p$DB_PASSWORD $DB_NAME < private/vvv.sql
fi

if [ ! -e wp-cli.local.yml ]; then
	echo -e "path: ./\nurl: http://vvv.cftesting.taco/" > wp-cli.local.yml
fi

git config core.fileMode false # usually we're not committing executable files

if [ ! -e .git/hooks/pre-commit ] && [ -e dev-lib/pre-commit ]; then
	echo "Install pre-commit hook"
	cd .git/hooks
	if ! ln -s ../../dev-lib/pre-commit .; then
		echo "Failed to create symlink for pre-commit hook, so falling back to copy"
		cp ../../dev-lib/pre-commit .
	fi
	cd - > /dev/null
fi

if ! wp --allow-root core is-installed; then
	wp --allow-root core install --title="cftesting" --admin_user="dev" --admin_password="dev" --admin_email="dev@127.0.0.1"
fi

# Now add any site-specific activations for themes and plugins, for instance
# wp --allow-root theme activate cftesting
# wp --allow-root plugin activate jetpack
