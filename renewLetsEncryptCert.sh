#!/bin/sh
# 
#
# Script to renew Lets Encrypt Cert automativaly N days before expiry
# designed to be run form Cron daily, and complain if wrong
#

# Dependencies
# openssl, timeout, sed, logger, service commands in the path
# letEncrypt installed and path set


SERVER=$1
PORT=${2:-443}
LIMIT=${3}
SERVICE=${4:-apache2}
TIMEOUT=10
SCRIPTNAME=`basename "$0"`

# /etc/letsencrypt/cli.ini
# email = greg@webarmadillo.net
# domains = www.webarmadillo.net, webarmadillo.net
# rsa-key-size = 4096
# webroot-path = /var/www
# authenticator = webroot

# no fiddling from here...

getCertAge () {
	# function to get age of cert from a given server/port/timeout
        # $DaysLeft to number of days remaining
	end_date="$(/usr/bin/timeout $TIMEOUT /usr/bin/openssl s_client -host $SERVER -port $PORT -showcerts < /dev/null 2>/dev/null | sed -n '/BEGIN CERTIFICATE/,/END CERT/p' | openssl x509 -enddate -noout 2>/dev/null | sed -e 's/^.*\=//')"

	if [ -n "$end_date" ]
	then
		end_date_seconds=$(date "+%s" --date "$end_date")
		now_seconds=$(date "+%s")
		DaysLeft=$((($end_date_seconds-$now_seconds)/24/3600))
	else
		exit 124
	fi
}

renewCert() {
	# function to try renewal with letsEncrypt
	log "Attempting renewal see: /var/log/letsencrypt/renew.log"
	if ! `sudo /home/myth/.local/share/letsencrypt/bin/letsencrypt certonly --renew-by-default > /var/log/letsencrypt/renew.log 2>&1`
	then
		OPS="letsencrypt renewal failed see: /var/log/letsencrypt/renew.log"
		log "${OPS}"
		printStdout "${OPS}"
		exit 1
	fi
	log "letsencrypt renewal success!"
}

restartService() {
	# function to restart the relevant serice
	# needs sudo
	log "Restarting ${SERVICE}"
	if ! `sudo service ${SERVICE} restart 2>&1 > /dev/null`
	then
		OPS="sudo service ${SERVICE} restart failed"
		log "${OPS}"
		printStdout "${OPS}"
		exit 2
	fi
	log "sudo service ${SERVICE} restart ok"
}

log() {
	# function to log with script name to syslog (or where ever logger goes)
	logger "${SCRIPTNAME}: " "${1}"
}

printStdout() {
	# function to print with timestamp to STDOUT
	echo `date '+%FT%T'` "${SCRIPTNAME}: " "${OPS}"
}

# get cert age
getCertAge

# check if it is still within limit
# if not tries renewal once
# and checks if it worked and bales if not

if [ ${DaysLeft} -ge ${LIMIT} ];then

	# nothing to do ... log then exit
	log "Cert on server:${SERVER} on port:${PORT} has ${DaysLeft} days left, more than ${LIMIT} days. Exiting"
	exit 0

else 
	
	# must need to renew
	log "Cert on server:${SERVER} on port:${PORT} has ${DaysLeft} days left, less than ${LIMIT} days. Attempting renew."
	
	# try renewal
	renewCert

	# try restarting server
	restartService
fi
# end
