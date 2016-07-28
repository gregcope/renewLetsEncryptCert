renewLetsEncryptCert
====================

Script to renew a lets Encrypt Cert!

* Supposed to be used as part of a cron job
* Assumes standalone server running on localhost
* Checks for configurable number of days left (if below this renews)
* Configurable port
* Configurable service restart
* If renewal fails, it bails
* Uses logger to log to syslog

Arguments
=========

renewLetsEncryptCert.sh [hostname] [httpsPort] [daysBeforeRenwal] [service to restart]

Example
=======

Example run, will try renewal when cert has less than 30 days left, and will restart apache2

    sudo ./renewLetsEncryptCert.sh localhost 443 30 apache2

sylog

This is a successful run

    $ grep renewLetsEncryptCert.sh /var/log/syslog 
    Jul 28 09:13:23 s myth: renewLetsEncryptCert.sh:  Cert on server:localhost on port:443 has 3 days left, less than 30 days. Attempting renew.
    Jul 28 09:13:23 s myth: renewLetsEncryptCert.sh:  Attempting renewal see: /var/log/letsencrypt/renew.log
    Jul 28 09:13:46 s myth: renewLetsEncryptCert.sh:  letsencrypt renewal success!
    Jul 28 09:13:46 s myth: renewLetsEncryptCert.sh:  Restarting apache2
    Jul 28 09:13:51 s myth: renewLetsEncryptCert.sh:  sudo service apache2 restart ok

