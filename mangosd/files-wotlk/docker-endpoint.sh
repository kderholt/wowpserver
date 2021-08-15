#!/bin/bash
cp /srv/wowconfig/mangosd.conf /srv/wow/mangos-wotlk/run/etc/;
cp /srv/wowconfig/playerbot.conf /srv/wow/mangos-wotlk/run/etc/;
cd /srv/wow/mangos-wotlk/run
./bin/mangosd -c etc/mangosd.conf -a etc/playerbot.conf
