#!/bin/bash -eu

# calc public ip
ip=`/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
echo "own ip address: $ip"

# wait 5 seconds for dns to
echo "waiting 5 seconds for dns"
sleep 5

# try until DNS is ready
url="mariadb-galera.marathon.containerip.dcos.thisdcos.directory"
members=""
digs=""

for i in {1..20}
do
	digs=`dig +short $url`
	if [ -z "$digs" ]; then
		echo "no DNS record found for $url"
	else
		# calculate discovery members
		members=`echo $digs | sed -e "s/$ip //g" -e "s/$ip//g" -e 's/ /,/g'`
		echo "calculated initial discovery members: $members"
		break
	fi
   sleep 2
done

echo "wsrep_node_address=\"$ip\"" >> /etc/mysql/conf.d/galera.cnf
echo "wsrep_cluster_address=\"gcomm://$members\"" >> /etc/mysql/conf.d/galera.cnf

echo "wsrep_node_address=\"$ip\""
echo "wsrep_cluster_address=\"gcomm://$members\""

dig_status=`echo $digs | sed -e "s/\.//g"`
ip_status=`echo $ip | sed -e "s/\.//g"`

echo $dig_status
echo $ip_status

# only the first one is allowed to start a new cluster
if [[ `echo $digs | sed -e "s/\.//g"` == `echo $ip | sed -e "s/\.//g"`* ]]; then
	echo "starting new cluster"
	/docker-entrypoint.sh mysqld --wsrep-new-cluster
else
	echo "joining existing cluster"
	# sleep another few seconds
	sleep 20
	# start mysqld
	/docker-entrypoint.sh mysqld
fi
