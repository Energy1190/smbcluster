#!/bin/bash

REALM=$(cat /etc/samba/smb.conf | grep realm)
IFS='=' read -ra DOMAIN <<< "$REALM"

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -u|--user)
    USER="$2"
    shift # past argument
    ;;
    -p|--password)
    PASSWORD="$2"
    shift # past argument
    ;;
    -ip|--domain-ip)
    DOMAIN-IP="$2"
    shift # past argument
    ;;
esac
shift # past argument or value
done

if [ -z ${USER} ] || [ -z ${PASSWORD} ] ; then
    echo "No login or password specified"
    exit 2
fi

if [ -z ${DOMAIN-IP} ] ; then
    echo "No domen controller address specified"
    exit 2
fi 

rm -f /etc/nsswitch.conf
cat <<EOF > /etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.

passwd:         compat winbind
group:          compat winbind
shadow:         compat winbind
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
EOF

rm -f /etc/krb5.conf
cat <<EOF > /etc/krb5.conf
[logging]
 default = FILE:/var/log/kerberos/krb5libs.log
 kdc = FILE:/var/log/kerberos/krb5kdc.log
 admin_server = FILE:/var/log/kerberos/kadmind.log

[libdefaults]
ticket_lifetime = 24000
default_realm = ${DOMAIN[1]}
dns_lookup_realm = false
dns_lookup_kdc = false
kdc_req_checksum_type = 2
checksum_type = 2
ccache_type = 1
forwardable = true
proxiable = true

[realms]
${DOMAIN[1]} = {
 kdc = ${DOMAIN-IP}:88
 default_domain = $(echo ${DOMAIN[1]} | tr '[:upper:]' '[:lower:]')
}

[domain_realm]
.$(echo ${DOMAIN[1]} | tr '[:upper:]' '[:lower:]') = ${DOMAIN[1]}

[pam]
debug = false
ticket_lifetime = 36000
renew_lifetime = 36000
forwardable = true
krb4_convert = false

[login]
krb4_convert = false
krb4_get_tickets = false
EOF

/etc/init.d/samba restart
/etc/init.d/winbind restart

net ads join -U ${USER}%${PASSWORD} -D $(echo ${DOMAIN[1]} | tr '[:upper:]' '[:lower:]')

/etc/init.d/samba restart
/etc/init.d/winbind restart

exec tail -f /var/log/samba/log.smbd
