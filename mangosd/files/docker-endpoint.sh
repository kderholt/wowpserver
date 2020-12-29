#!/bin/bash
cp /srv/wowconfig/mangosd.conf /srv/wow/mangos-classic/run/etc/;
cp /srv/wowconfig/playerbot.conf /srv/wow/mangos-classic/run/etc/;
cd /srv/wow/mangos-classic/run
./bin/mangosd -c etc/mangosd.conf -a etc/playerbot.conf
