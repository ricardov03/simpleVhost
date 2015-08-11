#!/bin/bash

##########################################################
#
# sompleVhost.sh
# @desc A simple way to administrate Apache Virtual Hosts.
#
# @autor Ricardo Vargas
# @email rvargas@seisigma.co
# @date 2015-08-10
#
##########################################################

# Paths
if [ -d /etc/apache2 ]; then
	VHOST_DIR=/etc/apache2/sites-available/
else 
	VHOST_DIR=/etc/httpd/conf.d/
fi
WWW_ROOT=/var/www/html

# Vars
ROOT_UID=0
TASK=$1
DOMAIN=$2
MSN_SYSTEM='\033[00;32m[ system ]\033[39m '
MSN_WARNING='\033[00;31m[ warning! ]\033[39m'
MSN_NOTICE='\033[00;33m[ notice ]\033[39m '

# Check - Root - User
#if [ "$UID" -ne "$ROOT_UID" ]; then
if [ "$(id -u)" != "0" ]; then
    echo "Sorry, you most be root to run this script."
    exit 0 
else
	echo '$MSN_NOTICE Root permitions passed...'; sleep 1
	echo -n '\n';

	# Retrieve parameters VHost information
	echo '-- Script Messages -- '

	if [ -n "$1" ] && [ -n "$2" ]; then
		DOMAIN=$1
		echo '[system] Domain identified:' $DOMAIN; sleep 1
		
		# Create document root site folder structure
		if [ -d $WWW_ROOT/$DOMAIN ]; then
			echo '[warning!] Site folder already exist!'; sleep 1
			if [ -e $VHOST_DIR/$DOMAIN ]; then
				echo '[warning!] This Virtual Host already exist!'; sleep 1
				echo '[system] Finalizing script.'
				echo -n '\n';
			fi
		else
			mkdir -p $WWW_ROOT/$DOMAIN
			mkdir -p $WWW_ROOT/$DOMAIN/cgi-bin
			mkdir -p $WWW_ROOT/$DOMAIN/htdocs
			mkdir -p $WWW_ROOT/$DOMAIN/logs
			mkdir -p $WWW_ROOT/$DOMAIN/backup
			mkdir -p $WWW_ROOT/$DOMAIN/backup/data
			mkdir -p $WWW_ROOT/$DOMAIN/backup/downloads
			mkdir -p $WWW_ROOT/$DOMAIN/backup/config
			echo '[system] Folder structure created.'; sleep 1

			# Set VHost Information
			if [ -e $VHOST_DIR/$DOMAIN ]; then
				echo '[warning!] The file already exist!'
			else
				VHFile="# \n# $DOMAIN \n# @desc:        Main VHost for the '$DOMAIN' website. \n# @autor:       createVHost script \n# @created:     $(date) \n# \n#################################################################### \n\n<VirtualHost *:80> \nServerAdmin webmaster@$DOMAIN \nServerName $DOMAIN \nServerAlias www.$DOMAIN \n\n# Indexes + Directory Root \n# DirectoryIndex index.html index.php \nDocumentRoot /home/www/$DOMAIN/htdocs/ \n\n# CGI Directory \nScriptAlias /cgi-bin/ /home/www/$DOMAIN/ \n<Directory /cgi-bin> \nOptions +ExecCGI \n</Directory> \n\n# Logfiles \nErrorLog /home/www/$DOMAIN/logs/$DOMAIN-error.log \nCustomLog /home/www/$DOMAIN/logs/$DOMAIN-access.log combined \n</VirtualHost>"

				echo $VHFile > $VHOST_DIR/$DOMAIN
				echo '[system] Virtual Host file ready!'; sleep 1

				echo '[system] Enable site...'; sleep 1
				a2ensite $DOMAIN
				echo '[system] Apache Server is restarted...'; sleep 1
				/etc/init.d/apache2 reload
				echo '[system] Done!'; sleep 1

				echo -n '\n';
				
				exit 0
			fi
		fi
	else
		echo "MSN_WARNING Please, provide a full domain name, i.e. 'example.com'"
		echo -n 'MSN_WARNING Run this script like "./createVHost task example.com" (Without quotes)\n\n'
		exit 0 
	fi
fi
exit 0
