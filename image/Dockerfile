FROM mariadb:10.1.20

RUN apt-get update && \ 
	apt-get install -y dnsutils net-tools && \
	apt-get clean

COPY galera.cnf /etc/mysql/conf.d/galera.cnf
COPY dcos-galera.sh /dcos-galera.sh
COPY drupaldb_backup.sql /drupaldb_backup.sql

ENTRYPOINT ["/dcos-galera.sh"]
