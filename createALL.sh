#!/bin/bash


if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
	echo "usage: ./createdb.sh <mangosdockerimage> <expansion> <ip>
mangosdockerimage: wowbase:xxx
expansion: [tbc|classic]
ip: ip/host"
	exit 0
fi

MySQLPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
MANGOSSQLPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
if [[ $2 == "tbc" ]]; then
	dbfolder="tbc-db"
	mangosfolder="mangos-tbc"
	MANGOS="tbcmangos"
	CHARACTERS="tbccharacters"
	REALMD="tbcrealmd"
	DBVOLUM="wowdb-tbc-remake"
	SERVERNAME="The Burning Crusade Realm"
	rm docker-compose-tbc.yml 2>&1
	rm realmd/files-tbc/realmd.conf 2>&1
	rm mangosd/files-tbc/mangosd.conf 2>&1
	sed "s|MySQLPASS|$MySQLPASS|g" docker-compose-tbc.yml.example >> docker-compose-tbc.yml
	sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" realmd/files-tbc/realmd.conf.example >> realmd/files-tbc/realmd.conf
	sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" mangosd/files-tbc/mangosd.conf.example >>mangosd/files-tbc/mangosd.conf

 
elif [[ $2 == "classic" ]]; then
	dbfolder="classic-db"
	mangosfolder="mangos-classic"
	MANGOS="classicmangos"
	CHARACTERS="classiccharacters"
	REALMD="classicrealmd"
	DBVOLUM="wowdb-classic"
	SERVERNAME="Classic Realm"
	rm docker-compose-classic.yml 2>&1
	rm realmd/files/realmd.conf 2>&1
	rm mangosd/files/mangosd.conf 2>&1
	sed "s|MySQLPASS|${MySQLPASS}|g" docker-compose-classic.yml.example >> docker-compose-classic.yml
	sed "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g" realmd/files/realmd.conf.example >> realmd/files/realmd.conf
	sed "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g" mangosd/files/mangosd.conf.example >> mangosd/files/mangosd.conf
fi
IPADDRESS=$3

rm  mariadb/files/db_create_mysql-EDITED.sql 2>&1
touch  mariadb/files/db_create_mysql-EDITED.sql
cat mariadb/files/db_create_mysql.sql >> mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g"  mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|CHARACTERS|${CHARACTERS}|g"  mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|REALMD|${REALMD}|g"  mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|MANGOS|${MANGOS}|g"  mariadb/files/db_create_mysql-EDITED.sql

rm mariadb/files/InstallFullDB-EDITED.config 2>&1
touch mariadb/files/InstallFullDB-EDITED.config
cat mariadb/files/InstallFullDB.config >> mariadb/files/InstallFullDB-EDITED.config
sed -i "s|MANGOSFOLDER|${mangosfolder}|g"  mariadb/files/InstallFullDB-EDITED.config
sed -i "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g"  mariadb/files/InstallFullDB-EDITED.config
sed -i "s|MANGOSDATABASE|${MANGOS}|g"  mariadb/files/InstallFullDB-EDITED.config

rm mariadb/files/post_update-EDITED.sql 2>&1
touch mariadb/files/post_update-EDITED.sql
cat mariadb/files/post_update.sql >> mariadb/files/post_update-EDITED.sql
sed -i "s|SERVERNAME|${SERVERNAME}|g"  mariadb/files/post_update-EDITED.sql
sed -i "s|ADDRESS|${IPADDRESS}|g"  mariadb/files/post_update-EDITED.sql

docker volume create $DBVOLUM
docker network create dbinit
docker run -ti -d --rm --name mariadb --network dbinit -e "MYSQL_ROOT_PASSWORD=${MySQLPASS}" -v "${DBVOLUM}:/var/lib/mysql" mariadb:10.1
docker run -ti -d --rm --name wowbaseinit --network dbinit $1 /bin/bash
sleep 15

docker cp mariadb/files/dbinit.sh wowbaseinit:/tmp
docker cp mariadb/files/InstallFullDB-EDITED.config wowbaseinit:/srv/wow/${dbfolder}/InstallFullDB.config
docker cp mariadb/files/db_create_mysql-EDITED.sql wowbaseinit:/srv/wow/${mangosfolder}/sql/create/db_create_mysql.sql
docker cp mariadb/files/post_update-EDITED.sql wowbaseinit:/tmp/post_update.sql
docker exec -ti wowbaseinit sh -c "chmod +x /tmp/dbinit.sh && /tmp/dbinit.sh ${mangosfolder} ${MySQLPASS} ${MANGOS} ${CHARACTERS} ${REALMD} ${dbfolder}"
docker stop mariadb wowbaseinit
docker network rm dbinit
