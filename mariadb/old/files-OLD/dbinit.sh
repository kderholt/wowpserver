#!/bin/bash
cd /srv/wow/mangos-classic
mysql -uroot -pmiwowpoc -hmariadb  < sql/create/db_create_mysql.sql
mysql -uroot -pmiwowpoc -hmariadb --database=classicmangos < sql/base/mangos.sql
for sql_file in $(ls sql/base/dbc/original_data/*.sql); do mysql -uroot -pmiwowpoc -hmariadb --database=classicmangos < $sql_file ; done
for sql_file in $(ls sql/base/dbc/cmangos_fixes/*.sql); do mysql -uroot -pmiwowpoc -hmariadb --database=classicmangos < $sql_file ; done
mysql -uroot -pmiwowpoc -hmariadb classiccharacters < sql/base/characters.sql
mysql -uroot -pmiwowpoc -hmariadb classicrealmd < sql/base/realmd.sql
cd /srv/wow/classic-db
./InstallFullDB.sh
