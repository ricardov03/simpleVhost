#!/bin/bash

##########################################################
#
# simpleVhost.sh
# @desc A simple way to administrate Apache Virtual Hosts.
#
# @autor Ricardo Vargas
# @email rvargas@seisigma.co
# @date 2015-08-10
#
##########################################################

# NOTE - All comments are printed like notifications.
# TODO - Add custom Apache Dir location.
# TODO - Read OS Name and Version.
	# TODO - Use this information for: Service Restart (CentOS, Debian, ETC)
# TODO - Configure folder structure permissions.
# TODO - Add Database Creation support.

# Vars
OS='none'
ROOT_UID=0
TASK=$1
DOMAIN=$2
BREAK='\n'
MSN_SYSTEM='\033[00;36m[  system  ]\033[39m'
MSN_WARNING='\033[00;33m[ warning! ]\033[39m'
MSN_NOTICE='\033[00;32m[  notice  ]\033[39m'
MSN_ERROR='\033[00;31m[  error!  ]\033[39m'

# Script Begin...
printf "$BREAK$MSN_SYSTEM Script begin...$BREAK"

# Check - Root - User
if [ "$(id -u)" != "0" ]; then
	printf "$MSN_WARNING Sorry, you most be root to run this script.$BREAK"; sleep 1
	printf "$MSN_SYSTEM Exiting...$BREAK$BREAK"; sleep 2
	exit 0 
else
	# PATHS
	WWW_ROOT=/var/www/html
	if [ -d /etc/apache2 ]; then
        	VHOST_DIR=/etc/apache2/sites-available/
		OS='debian'
	elif [ -d /etc/httpd ]; then
        	VHOST_DIR=/etc/httpd/conf.d/
		OS='centos'
	else
        	printf "$MSN_WARNING The system can't find the Apache Server folder.$BREAK"; sleep 1
        	printf "$MSN_SYSTEM Exiting...$BREAK$BREAK"; sleep 2
        	exit 0;
	fi

	printf "$MSN_NOTICE Root permitions passed...$BREAK$BREAK"

	# Retrieve parameters VHost information
	printf "   -- Script Messages --$BREAK$BREAK"; sleep 1

	if [ -n "$1" ] && [ -n "$2" ]; then
		printf "$MSN_NOTICE ToDo:	$TASK$BREAK"
		printf "$MSN_NOTICE Domain:	$DOMAIN$BREAK"

		case "$TASK" in
			create)
				if [ -d $WWW_ROOT/$DOMAIN ] && [ -d $WWW_ROOT/$DOMAIN/logs ] && [ -d $WWW_ROOT/$DOMAIN/htdocs ] && [ -d $WWW_ROOT/$DOMAIN/backup ]; then
					printf "$MSN_WARNING Domain folder exist and have content. Skip folder creation.$BREAK";
					printf "$MSN_SYSTEM Exiting...$BREAK$BREAK"; sleep 2
					exit 1;
				else
					printf "$MSN_NOTICE Website folder doesn't exist.$BREAK"; sleep 1
					printf "$MSN_NOTICE Creating folder tree.$BREAK"; sleep 1
                                        mkdir -p $WWW_ROOT/$DOMAIN
                                        mkdir -p $WWW_ROOT/$DOMAIN/logs
                                        mkdir -p $WWW_ROOT/$DOMAIN/htdocs
                                        mkdir -p $WWW_ROOT/$DOMAIN/backup
                                        mkdir -p $WWW_ROOT/$DOMAIN/backup/db
                                        mkdir -p $WWW_ROOT/$DOMAIN/backup/data
                                        mkdir -p $WWW_ROOT/$DOMAIN/downloads
                                        printf "$MSN_NOTICE Folder structure created.$BREAK"

                                	if [ -e $VHOST_DIR/vhost-$DOMAIN.conf ]; then
                                        	printf "$MSN_WARNING Virtual Host file already exist!$BREAK"; sleep 1
                                        	printf "$MSN_SYSTEM Exiting...$BREAK$BREAK"; sleep 2
                                        	exit 0;
                                	else
                                        	printf "$MSN_NOTICE Virtual Host file doesn't exist.$BREAK"; sleep 1
                                        	printf "$MSN_NOTICE Creating site Virtual Host file.$BREAK"
                                        	printf "#
# $DOMAIN
# @desc Main VHost fot the '$DOMAIN' website.
# @generator simpleVHost.sh
# @created $(date)
#
############################################################

<VirtualHost *:80>
        ServerAdmin     admin@$DOMAIN
        ServerName      $DOMAIN
        ServerAlias     www.$DOMAIN

        DocumentRoot $WWW_ROOT/$DOMAIN/htdocs

        ErrorLog $WWW_ROOT/$DOMAIN/logs/$DOMAIN-error.log
        CustomLog $WWW_ROOT/$DOMAIN/logs/$DOMAIN-access.log combined
</VirtualHost>
" > $VHOST_DIR/vhost-$DOMAIN.conf
						printf "$MSN_NOTICE Virtual Host file ready!$BREAK"
						printf "$MSN_NOTICE Enabling site...$BREAK"
						if [ $OS == 'debian' ]; then
							a2ensite vhost-$DOMAIN.conf
							printf "$MSN_SYSTEM Site enabled.$BREAK"; sleep 1
						fi	
						printf "$MSN_WARNING Applying configuration. Restarting Apache Server...$BREAK"; sleep 1
						if [ $OS == 'debian' ]; then
							/etc/init.d/apache2 reload
						elif [ $OS == 'centos' ]; then
							/etc/init.d/httpd reload
						else
							printf "$MSN_WARNING Uhmm... Where is Apache?"
							printf "$MSN_SYSTEM Exiting..."
						fi
						printf "$MSN_NOTICE Apache Server restarted.$BREAK"
						printf "$MSN_SYSTEM Script complete! Exiting...$BREAK$BREAK"; sleep 2
						exit 0;
					fi
				fi	
				;;
			backup) printf "Backup..."
				exit 0
				;;
			remove) printf "Remove..."
				exit 0
				;;
		esac
	else
		printf "$MSN_ERROR Please, provide all require parameters.$BREAK"; sleep 1
		printf "$MSN_NOTICE Run this script like \"sudo ./createVHost [task] [example.com]\" (Without quotes)$BREAK$BREAK"; sleep 1
		exit 0 
	fi
fi
exit 0
