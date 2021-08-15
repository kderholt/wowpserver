#!/bin/bash
source commonInclude.sh

if [[ -z "$1" || -z "$2" ]]; then
	echo "usage: ./installWoW.sh <expansion> <desire> 
expansion: [classic|tbc]
desire: [fullclean|clean|install]

clean - remove database, mangos setup
fullclean - remove database, mangos setup and baseimage
install - compile baseimage (will skip if exist), create a new database (will abort install if db exist), compile maps (skip if exists)
"
	exit 0
fi

MySQLPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
#MySQLPASS="3ZDL7tWCgLqtnpb"
MANGOSSQLPASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 15 | head -n 1)
#MANGOSSQLPASS="3ZDL7tWCgLqtnpbMANGO"
IPADDRESS=$(curl -s 'https://api.ipify.org?format=text')


#selector()
main() {
if [[ $1 == "tbc" ]]; then
	echo "TBC selected"
        dbfolder="tbc-db"
        mangosfolder="mangos-tbc"
        MANGOS="tbcmangos"
        CHARACTERS="tbccharacters"
        REALMD="tbcrealmd"
        DBVOLUM="wowdb-tbc"
        SERVERNAME="The Burning Crusade Realm"
	BASEIMAGE="tbc-base:latest"
	WOWCLIENT="wow-client-tbc"
	MANGOSVOLUME="files-tbc"
elif [[ $1 == "classic" ]]; then
	echo "Classic selected"
	dbfolder="classic-db"
	mangosfolder="mangos-classic"
	MANGOS="classicmangos"
	CHARACTERS="classiccharacters"
	REALMD="classicrealmd"
	DBVOLUM="wowdb-classic"
	SERVERNAME="Classic Realm"
	BASEIMAGE="classic-base:latest"
	WOWCLIENT="wow-client-classic"
	MANGOSVOLUME="files-classic"
elif [[ $1 == "wotlk" ]]; then
        echo "WotLK selected"
        dbfolder="wotlk-db"
        mangosfolder="mangos-wotlk"
        MANGOS="wotlkmangos"
        CHARACTERS="wotlkcharacters"
        REALMD="wotlkrealmd"
        DBVOLUM="wowdb-wotlk"
        SERVERNAME="WotLK Realm"
        BASEIMAGE="wotlk-base:latest"
        WOWCLIENT="wow-client-wotlk"
        MANGOSVOLUME="files-wotlk"
fi
if [[ $2 == "install" ]]; then
	MAPS=0
	BASEIMAGEEXISTS=0
	if existsDatabase "$1"; then exit 0; fi
	if existsMaps "$MANGOSVOLUME" ; then MAPS="1"; fi
	if existsBaseimage "$BASEIMAGE" ; then 
		BASEIMAGEEXISTS="1"
       	fi
	if [[ $BASEIMAGEEXISTS -eq 0 ]]; then
		createBaseImage "$1" "$BASEIMAGE"
	fi
	installConfig "$1" "$MANGOSVOLUME"
	createMysqlBaseFiles
	createcMangoBaseFiles
	startDockercontainers "$DBVOLUM" "$MySQLPASS" "$BASEIMAGE" "dbinit"
	sleep 15
	databaseInstall "$dbfolder" "$mangosfolder" "$MySQLPASS" "$MANGOS" "$CHARACTERS" "$REALMD"
	if [[ $MAPS -eq 0 ]]; then
		extractGamefiles "$WOWCLIENT" "$MANGOSVOLUME" "$BASEIMAGE" "$mangosfolder"
	fi
	cleanupInit
	echo "Installation complete, you can now run docker-compose -f docker-compose-$1.yml up -d to start your server"

elif [[ $2 == "clean" ]]; then
	gameClean "$1" "$DBVOLUM"
elif [[ $2 == "fullclean" ]]; then
	gameFullClean "$1" "$MANGOSVOLUME" "$DBVOLUM" "$BASEIMAGE"
fi

}


main "$@"
#baseInstall
#extractClassicGamefiles
#existingClassicInstall
#existsDatabase "$1"
# existsBaseimage "classic-base:latest"
