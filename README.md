# cMANGoS docker stack - World of Warcraft



**#prerequisits**
1. world of warcraft client
2. docker


**#install**
create the wowclient folder in the root:
```
wow-client-classic 	- vanilla client folder
wow-client-tbc  - tbc client folder
wow-client-wotlk  - wotlk client folder
```
then run:
```
./installWoW.sh 
```
The usage is displayed here:
```
usage: ./installWoW.sh <expansion> <desire>
expansion: [classic|tbc]
desire: [fullclean|clean|install]

clean - remove database, mangos setup
fullclean - remove database, mangos setup and baseimage
install - compile baseimage (will skip if exist), create a new database (will abort install if db exist), compile maps (skip if exists)
```



**#underthehood**

The setup is based of 3 docker containers.
worldserver, authserver and the database server.

The database is a standard mariadb docker image.
world and authserver is based of an image we create which I call baseimage.

The baseimage is ran 2 times with different executeable and linked with docker networking.
(There is obviously better ways of doing this, but this felt convenient at the time)


Install will create a baseimage for the expansion selected. - this compiling process will take time, but is only nessesary to do once
The database is created within a docker volume. This means you can do docker-compose down (which deletes all containers) and run a docker-compose up and you will have all your settings. No data will be lost.

If we dont see the maps/vmaps/mmaps/dbc folders in the mangos structure, we will try to extract the mapfiles. - this is also a timeconsuming operation.

**#settings**
default in all expansions the character you create will be max level.

you can only run one expansion at the same time. We could make it run on different ports but not sure if wowclient support this. either way, get multiple IP and your good.
You can run one expansion, do a docker down, start up another one without losing the first expansion data.

Mangos comes with some default users. 
Administrator/Administrator will work out of the box and is good for testing.

I suggest to disable this user and create your own, in fact disable all the predefined users for security reasons. (I ususally did this in the mysql database, but you can maybe do this in the mangos interface aswell)

To access the mango commandline you can do a "docker ps" - find your worldserver container. then do:
```
docker attach <worldserver container hash/name>
```

A quick command to create a user would be:
```
account create <username> <password> <expansionnumber[1=tbc, 2=wotlk]>
account set gmlevel <username> 3
```
This will get you up and running quick

To disconnect from the console without shutting the worldserver down:
```
control + p + q
```



The inspiration to this I can thank this blog for: 
https://www.osrsbox.com/blog/2019/04/13/installing-a-wow-vanilla-server-on-ubuntu-linux/#preparing-ubuntu





