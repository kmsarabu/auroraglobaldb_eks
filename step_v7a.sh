#!/bin/bash

ACCOUNT_ID=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.accountId')
AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

roendpoint=$(aws rds describe-db-clusters --query 'DBClusters[?(TagList[?(Key == `Application` && Value == `EKSAURGDB`)])].ReaderEndpoint' --output text)

replicaSourceArn=$(aws rds describe-db-clusters --query 'DBClusters[?(TagList[?(Key == `Application` && Value == `EKSAURGDB`)])].ReplicationSourceIdentifier' --output text)

runscript=0

if [[ -z "${replicaSourceArn}" ]]; then
	rwendpoint=$(aws rds describe-db-clusters --query 'DBClusters[?(TagList[?(Key == `Application` && Value == `EKSAURGDB`)])].Endpoint' --output text)
else
	runscript=1
	rwregion=`echo $replicaSourceArn |awk -F: '{print $4}'`
	rwendpoint=$(aws rds describe-db-clusters --region ${rwregion} --query 'DBClusters[?(TagList[?(Key == `Application` && Value == `EKSAURGDB`)])].Endpoint' --output text)
fi

echo Aurora RO Endpoint : $roendpoint
echo Aurora RW Endpoint : $rwendpoint

if [[ -z $roendpoint || -z $rwendpoint ]]; then
	echo Error in determining ro / rw endpoints for Aurora Clusters
	exit 1
fi

## Generate configuration for PgBouncer
## Get DB Credentials using aurora-pg/EKSGDB1
secret=$(aws secretsmanager get-secret-value --secret-id aurora-pg/EKSGDB1 --query SecretString --output text)
dbuser=`echo "$secret" | sed -n 's/.*"username":["]*\([^(",})]*\)[",}].*/\1/p'`
dbpass=`echo "$secret" | sed -n 's/.*"password":["]*\([^(",})]*\)[",}].*/\1/p'`

if [[ -z $dbuser || -z $dbpass ]]; then
	echo Error in extracting database user credentials from secretsmanager
	exit 1
fi

if [[ $runscript -eq 1 ]]; then
export PGPASSWORD=$dbpass
psql -h $rwendpoint -U $dbuser -p 5432 -d postgres -f setup_schema.sql
fi

DBUSER=dbuser1
DBPASSWD=eksgdbdemo
dbpass1=`echo -n "${DBPASSWD}${DBUSER}" | md5sum | awk '{print $1}'`
echo \"${DBUSER}\" \"md5${dbpass1}\" > /tmp/userlist.txt
dbpass1=`echo -n "${dbpass}${dbuser}" | md5sum | awk '{print $1}'`
echo \"${dbuser}\" \"md5${dbpass1}\" >> /tmp/userlist.txt

echo "[databases]
gdbdemo = host=${rwendpoint} port=5432 dbname=eksgdbdemo
gdbdemo-ro = host=${roendpoint} port=5432 dbname=eksgdbdemo
[pgbouncer]
logfile = /tmp/pgbouncer.log
pidfile = /tmp/pgbouncer.pid
listen_addr = *
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
auth_user = ${DBUSER}
stats_users = stats, root, pgbouncer
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 100
tcp_keepalive = 1
tcp_keepidle = 1
tcp_keepintvl = 11
tcp_keepcnt = 3
tcp_user_timeout = 12500" > /tmp/pgbouncer.ini

pgbouncerini=`cat  /tmp/pgbouncer.ini | base64 --wrap=0`
userlisttxt=`cat  /tmp/userlist.txt | base64 --wrap=0`

sed -e "s/%pgbouncerini%/$pgbouncerini/g" -e "s/%userlisttxt%/$userlisttxt/g" PgBouncer/pgbouncer_kubernetes.yml > retailapp/eks/pgbouncer_kubernetes.yml

kubectl apply -f retailapp/eks/pgbouncer_kubernetes.yml

