#!/bin/bash
cp /srv/wowconfig/realmd.conf /srv/wow/mangos-wotlk/run/etc/;
cd /srv/wow/mangos-wotlk/run && ./bin/realmd -c etc/realmd.conf
