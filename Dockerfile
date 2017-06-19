FROM debian

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y winbind libnss-winbind apt-get install krb5-user libpam-krb5 samba

ADD start.sh /start.sh

RUN chmod +x /start.sh

EXPOSE 88 137/udp 138/udp 139 445 

ENTRYPOINT ["/start.sh"]
