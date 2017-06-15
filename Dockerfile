FROM debian

RUN apt-get update && apt-get upgrade -y
RUN apt-get install samba ctdb

ENTRYPOINT ['bash']
