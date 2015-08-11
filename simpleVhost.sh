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
FS=1
ROOT_UID=0
TASK=$1
DOMAIN=$2
BREAK='\n'
MSN_SYSTEM='\033[00;36m[  system  ]\033[39m'
MSN_WARNING='\033[00;33m[ warning! ]\033[39m'
MSN_NOTICE='\033[00;32m[  notice  ]\033[39m'
MSN_ERROR='\033[00;31m[  error!  ]\033[39m'

# Script Begin
printf "$BREAK$MSN_SYSTEM Script begin...$BREAK"; sleep 1
#printf "$TASK - $DOMAIN - $VHOST_DIR" --ToDelete

# Check - Root - User
if [ "$(id -u)" != "0" ]; then
    printf "$MSN_WARNING Sorry, you most be root to run this script.$BREAK$BREAK"; sleep 1
    exit 0 
else
	printf "$MSN_NOTICE Root permitions passed..."; sleep 1
	printf "$BREAK$BREAK";

	# Retrieve parameters VHost information
	printf "   -- Script Messages --$BREAK$BREAK"

	if [ -n "$1" ] && [ -n "$2" ]; then
		printf "$MSN_NOTICE ToDo:	$TASK$BREAK"; sleep 1
		printf "$MSN_NOTICE Domain:	$DOMAIN$BREAK"; sleep 1

		case "$TASK" in
			create)
				if [ -d $WWW_ROOT/$DOMAIN ]; then
					printf "$MSN_WARNING Domain folder exist!$BREAK"; sleep 1
					if [ -d $WWW_ROOT/$DOMAIN/logs ] && [ -d $WWW_ROOT/$DOMAIN/htdocs ] && [ -d $WWW_ROOT/$DOMAIN/backup ]; then
						printf "$MSN_NOTICE Domain folder without content.$BREAK"; sleep 1
						printf "$MSN_WARNING Removing empty folder...$BREAK";
						rm -r $WWW_ROOT/$DOMAIN
					else
						FS=0
						printf "$MSN_NOTICE"; sleet
						
					if  [ -e $VHOST_DIR/$DOMAIN.vhost ]; then
						printf "$MSN_ERROR Virtual Host file already exist!$BREAK"; sleep 1
						printf "$MSN_NOTICE No more actions...Finalizing script...$BREAK$BREAK"; sleep 2
						exit 0;
					else
						printf "$MSN_NOTICE Virtual Host file doesn't exist.$BREAK"; sleep 1	
					fi
				else
					printf "$MSN_NOTICE Website folder doesn't exist.$BREAK"; sleep 1
				fi

				if [ -d $WWW_ROOT/$DOMAIN  ]; then; FS=1; fi
				if [ $FS == 1 ]; then
					printf "$MSN_NOTICE Creating folder tree.$BREAK"; sleep 1
					mkdir -p $WWW_ROOT/$DOMAIN
					mkdir -p $WWW_ROOT/$DOMAIN/logs
					mkdir -p $WWW_ROOT/$DOMAIN/htdocs
					mkdir -p $WWW_ROOT/$DOMAIN/backup
					mkdir -p $WWW_ROOT/$DOMAIN/backup/db
					mkdir -p $WWW_ROOT/$DOMAIN/backup/data
					mkdir -p $WWW_ROOT/$DOMAIN/downloads
					printf "$MSN_NOTICE Folder structure created.$BREAK"; sleep 1
				fi

				exit 0;
				;;
			remove)
				printf "Remove...";;
		esac
exit 0;
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
		printf "$MSN_ERROR Please, provide all require parameters.$BREAK"; sleep 1
		printf "$MSN_NOTICE Run this script like \"sudo ./createVHost [task] [example.com]\" (Without quotes)$BREAK$BREAK"; sleep 1
		exit 0 
	fi
fi
exit 0
