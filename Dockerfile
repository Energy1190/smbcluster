FROM debian

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y samba ctdb

RUN mkdir -p /test && mkdir -p /share
RUN touch /test/lockfile

ADD smb.conf /etc/samba/smb.conf
ADD ctdb /etc/default/ctdb
ADD ip /etc/ctdb/public_addesses
ADD ip /etc/ctdb/nodes

EXPOSE 137/udp 138/udp 139 445 4379

RUN service ctdb start

ENTRYPOINT ['tail']
