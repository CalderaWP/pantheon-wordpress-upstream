#!/bin/bash

echo -n "Firing up vagrant..."
vagrant ssh -c '
	sudo rm /tmp/php_errors.cftesting.taco.log;
	sudo touch /tmp/php_errors.cftesting.taco.log;
	sudo chmod a+w /tmp/php_errors.cftesting.taco.log;
	echo " now to tailing:";
	tail -f /tmp/php_errors.cftesting.taco.log
'
