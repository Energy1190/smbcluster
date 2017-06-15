FROM debian

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y samba

EXPOSE 137/udp 138/udp 139 445 

RUN /etc/init.d/samba restart

CMD ["/bin/tail"]
