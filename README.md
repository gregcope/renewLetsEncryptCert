renewLetsEncryptCert
====================

Script to renew a lets Encrypt Cert!

* Supposed to be used as part of a cron job
* assumes standalone server running on localhost
* Checks for configurable number of days left (if below this renews)
* Configurable port
* Configurable service restart
* If renewal fails, it bails
* Uses logger to log to syslog

Example
=======

Example run, will try renewal when cert has less than 30 days left, and will restart apache2

    sudo ./renewLetsEncryptCert.sh localhost 443 30 apache2
