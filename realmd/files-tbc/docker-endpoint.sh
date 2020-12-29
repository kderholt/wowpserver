#!/bin/bash
cp /srv/wowconfig/realmd.conf /srv/wow/mangos-tbc/run/etc/;
cd /srv/wow/mangos-tbc/run && ./bin/realmd -c etc/realmd.conf
