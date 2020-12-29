#!/bin/bash


if [[ -z "$1" && -z "$2" ]]; then
	echo "usage: ./createdb.sh <mangosdockerimage> <expansion>
mangosdockerimage: wowbase:xxx
expansion: [tbc|classic]"
	exit 0
fi

MySQLPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
MANGOSSQLPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
if [[ $2 -eq "tbc" ]]; then
	dbfolder="tbc-db"
	mangosfolder="mangos-tbc"
	MANGOS="tbcmangos"
	CHARACTERS="tbccharacters"
	REALMD="tbcrealmd"
	DBVOLUM="wowdb-tbc-remake"
	rm docker-compose-tbc.yml 2>&1
	rm realmd/files-tbc/realmd.conf 2>&1
	rm mangosd/files-tbc/mangosd.conf 2>&1
	sed "s|MySQLPASS|$MySQLPASS|g" docker-compose-tbc.yml.example >> docker-compose-tbc.yml
	sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" realmd/files-tbc/realmd.conf.example >> realmd/files-tbc/realmd.conf
	sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" mangosd/files-tbc/mangosd.conf.example >>mangosd/files-tbc/mangosd.conf

 
elif [[ $2 -eq "classic" ]]; then
	dbfolder="classic-db"
	mangosfolder="mangos-classic"
	MANGOS="classicmangos"
	CHARACTERS="classiccharacters"
	REALMD="classicrealmd"
	DBVOLUM="wowdb-classic"
	rm docker-compose-classic.yml 2>&1
	rm realmd/files/realmd.conf 2>&1
	rm mangosd/files/mangosd.conf 2>&1
	sed "s|MySQLPASS|$MySQLPASS|g" docker-compose-classic.yml.example >> docker-compose-classic.yml
	sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" realmd/files/realmd.conf.example >> realmd/files/realmd.conf
	sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" mangosd/files/mangosd.conf.example >> mangosd/files/mangosd.conf
fi

rm  mariadb/files/db_create_mysql-EDITED.sql 2>&1
touch  mariadb/files/db_create_mysql-EDITED.sql
sed "s|MANGOS|$MANGOS|g" mariadb/files/db_create_mysql.sql >> mariadb/files/db_create_mysql-EDITED.sql
sed "s|CHARACTERS|$CHARACTERS|g" mariadb/files/db_create_mysql.sql >>  mariadb/files/db_create_mysql-EDITED.sql
sed "s|REALMD|$REALMD|g" mariadb/files/db_create_mysql.sql >> mariadb/files/db_create_mysql-EDITED.sql
sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" mariadb/files/db_create_mysql.sql >> mariadb/files/db_create_mysql-EDITED.sql

rm mariadb/files/InstallFullDB-EDITED.config 2>&1
touch mariadb/files/InstallFullDB-EDITED.config
sed "s|MANGOSFOLDER|$mangosfolder|g" mariadb/files/InstallFullDB.config >> mariadb/files/InstallFullDB-EDITED.config
sed "s|MANGOSUSERPASS|$MANGOSSQLPASS|g" mariadb/files/InstallFullDB.config >> mariadb/files/InstallFullDB-EDITED.config
sed "s|MANGOSDATABASE|$MANGOS|g" mariadb/files/InstallFullDB.config >> mariadb/files/InstallFullDB-EDITED.config

docker volume create $DBVOLUM
docker network create dbinit
docker run -ti -d --rm --name mariadb --network dbinit -e "MYSQL_ROOT_PASSWORD=${MySQLPASS}" -v "${DBVOLUM}:/var/lib/mysql" mariadb:10.1
docker run -ti -d --rm --name wowbaseinit --network dbinit $1 /bin/bash
sleep 15

docker cp mariadb/files/dbinit.sh wowbaseinit:/tmp
docker cp mariadb/files/InstallFullDB-EDITED.config wowbaseinit:/srv/wow/${dbfolder}/InstallFullDB.config
docker cp mariadb/files/db_create_mysql-EDITED.sql wowbaseinit:/srv/wow/${mangosfolder}/sql/create/db_create_mysql.sql
docker exec -ti wowbaseinit sh -c "chmod +x /tmp/dbinit.sh && /tmp/dbinit.sh $mangosfolder $MySQLPASS $MANGOS $CHARACTERS $REALMD $dbfolder"
docker stop mariadb wowbaseinit
docker network rm dbinit
