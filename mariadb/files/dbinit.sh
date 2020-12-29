#!/bin/bash
cd /srv/wow/${1}
mysql -uroot -p${2} -hmariadb  < sql/create/db_create_mysql.sql
mysql -uroot -p${2} -hmariadb --database=$3 < sql/base/mangos.sql
for sql_file in $(ls sql/base/dbc/original_data/*.sql); do mysql -uroot -p${2} -hmariadb --database=$3 < $sql_file ; done
for sql_file in $(ls sql/base/dbc/cmangos_fixes/*.sql); do mysql -uroot -p${2} -hmariadb --database=$3 < $sql_file ; done
mysql -uroot -p${2} -hmariadb $4 < sql/base/characters.sql
mysql -uroot -p${2} -hmariadb $5 < sql/base/realmd.sql
mysql -uroot -p${2} -hmariadb $5 < /tmp/post_update.sql

cd /srv/wow/$6
./InstallFullDB.sh

