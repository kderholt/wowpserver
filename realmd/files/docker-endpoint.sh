#!/bin/bash
cp /srv/wowconfig/realmd.conf /srv/wow/mangos-classic/run/etc/;
cd /srv/wow/mangos-classic/run && ./bin/realmd -c etc/realmd.conf
