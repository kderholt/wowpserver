#!/bin/bash
cp /srv/wowconfig/mangosd.conf /srv/wow/mangos-tbc/run/etc/;
cp /srv/wowconfig/playerbot.conf /srv/wow/mangos-tbc/run/etc/;
cd /srv/wow/mangos-tbc/run
./bin/mangosd -c etc/mangosd.conf -a etc/playerbot.conf
