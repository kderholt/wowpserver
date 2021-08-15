#!/bin/bash
existsDatabase() {
dbvolumecreated=$(docker volume ls |grep $1 |awk -F ' ' ' {print $2}')
if [[ "$dbvolumecreated" ]]; then
    echo "Existing database: $dbvolumecreated found."
    true
else
    false
fi
}

existsMaps(){
if [[ -d "mangosd/$1/dbc" && -d "mangosd/$1/maps" && -d "mangosd/$1/maps" && -d "mangosd/$1/vmaps" ]]; then
#    echo "Existing map folders detected."
    true
else
    false
fi
}

existsBaseimage(){
baseimagecreated=$(docker images $1 -q)
#echo "this is the baseimage id $baseimagecreated"
if [[ "$baseimagecreated" ]]; then
        true
else
	false
fi
}

startDockercontainers(){
docker volume rm $1 2>/dev/null
docker volume create $1
docker network rm $4 2>/dev/null
docker network create $4
docker run -ti -d --rm --name mariadb --network $4 -e "MYSQL_ROOT_PASSWORD=${2}" -v "${1}:/var/lib/mysql" mariadb:10.1
docker run -ti -d --rm --name wowbaseinit --network $4 $3 /bin/bash
}

databaseInstall() {
echo "Copy: dbinit.sh into wowbaseinit container"
docker cp mariadb/files/dbinit.sh wowbaseinit:/tmp
echo "Copy: InstallFullDB-EDITED.config into wowbaseinit container"
docker cp mariadb/files/InstallFullDB-EDITED.config wowbaseinit:/srv/wow/${1}/InstallFullDB.config
echo "Copy: db_create_mysql-EDITED.sql into wowbaseinit container"
docker cp mariadb/files/db_create_mysql-EDITED.sql wowbaseinit:/srv/wow/${2}/sql/create/db_create_mysql.sql
echo "Copy: post_update-EDITED.sql into wowbaseinit container"
docker cp mariadb/files/post_update-EDITED.sql wowbaseinit:/tmp/post_update.sql
echo "running chmod +x /tmp/dbinit.sh && /tmp/dbinit.sh ${2} ${3} ${4} ${5} ${6} ${1} on wowbaseinit"
docker exec -ti wowbaseinit sh -c "chmod +x /tmp/dbinit.sh && /tmp/dbinit.sh ${2} ${3} ${4} ${5} ${6} ${1}"
docker stop wowbaseinit
docker stop mariadb
}

createMysqlBaseFiles() {
rm  mariadb/files/db_create_mysql-EDITED.sql 2>/dev/null
touch  mariadb/files/db_create_mysql-EDITED.sql
cat mariadb/files/db_create_mysql.sql >> mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g"  mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|CHARACTERS|${CHARACTERS}|g"  mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|REALMD|${REALMD}|g"  mariadb/files/db_create_mysql-EDITED.sql
sed -i "s|MANGOS|${MANGOS}|g"  mariadb/files/db_create_mysql-EDITED.sql
}

createcMangoBaseFiles(){
rm mariadb/files/InstallFullDB-EDITED.config 2>/dev/null
touch mariadb/files/InstallFullDB-EDITED.config
cat mariadb/files/InstallFullDB.config >> mariadb/files/InstallFullDB-EDITED.config
sed -i "s|MANGOSFOLDER|${mangosfolder}|g"  mariadb/files/InstallFullDB-EDITED.config
sed -i "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g"  mariadb/files/InstallFullDB-EDITED.config
sed -i "s|MANGOSDATABASE|${MANGOS}|g"  mariadb/files/InstallFullDB-EDITED.config

rm mariadb/files/post_update-EDITED.sql 2>/dev/null
touch mariadb/files/post_update-EDITED.sql
cat mariadb/files/post_update.sql >> mariadb/files/post_update-EDITED.sql
sed -i "s|SERVERNAME|${SERVERNAME}|g"  mariadb/files/post_update-EDITED.sql
sed -i "s|ADDRESS|${IPADDRESS}|g"  mariadb/files/post_update-EDITED.sql
}

extractGamefiles(){
docker run -ti -d -v "${PWD}/$1:/wow-client" --rm --name wowclientextract $3 /bin/bash
docker exec -ti wowclientextract sh -c "cp /srv/wow/$4/contrib/extractor_scripts/* /wow-client"
docker exec -ti wowclientextract sh -c "cp /srv/wow/$4/run/bin/tools/* /wow-client"
docker exec -ti wowclientextract sh -c "cd /wow-client;chmod u+x ExtractResources.sh;./ExtractResources.sh a"
cp -aR ./$1/dbc mangosd/$2/
cp -aR ./$1/maps mangosd/$2/
cp -aR ./$1/mmaps mangosd/$2/
cp -aR ./$1/vmaps mangosd/$2/
docker stop wowclientextract
}

installConfig() {
        rm docker-compose-${1}classic.yml 2>/dev/null
        rm realmd/${2}/realmd.conf 2>/dev/null
        rm mangosd/${2}/mangosd.conf 2>/dev/null
        sed "s|MySQLPASS|${MySQLPASS}|g" docker-compose-${1}.yml.example >> docker-compose-${1}.yml
        sed "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g" realmd/${2}/realmd.conf.example >> realmd/${2}/realmd.conf
        sed "s|MANGOSUSERPASS|${MANGOSSQLPASS}|g" mangosd/${2}/mangosd.conf.example >> mangosd/${2}/mangosd.conf
}



createBaseImage(){
cd base-${1}; docker build -t ${2} . 2>&1; cd ..;
}

cleanupInit(){
echo "will try to clean up temp mysql container and the network for the initial db import."
docker stop mariadb wowbaseinit wowclientextract 2>/dev/null
docker network rm dbinit 2>/dev/null
}


gameClean(){
rm docker-compose-${1}.yml 2>/dev/null
rm mariadb/files/db_create_mysql-EDITED.sql 2>/dev/null
rm mariadb/files/InstallFullDB-EDITED.config 2>/dev/null
rm mariadb/files/post_update-EDITED.sql 2>/dev/null
docker volume rm $2 2>/dev/null
}


gameFullClean(){
rm docker-compose-${1}.yml 2>/dev/null
rm mariadb/files/db_create_mysql-EDITED.sql 2>/dev/null
rm mariadb/files/InstallFullDB-EDITED.config 2>/dev/null
rm mariadb/files/post_update-EDITED.sql 2>/dev/null
rm -r mangosd/${2}files-classic/dbc 2>/dev/null
rm -r mangosd/${2}files-classic/maps 2>/dev/null
rm -r mangosd/${2}files-classic/maps 2>/dev/null
rm -r mangosd/${2}files-classic/vmaps 2>/dev/null
rm realmd/${2}files-classic/realmd.conf 2>/dev/null
rm mangosd/${2}files-classic/mangosd.conf 2>/dev/null
docker volume rm $3 2>/dev/null
docker rmi $4 2>/dev/null
}

