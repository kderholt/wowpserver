from ubuntu:focal

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y --no-install-recommends && apt-get install -y --no-install-recommends \
build-essential \
gcc \
g++ \
automake \
git-core \
autoconf \
make patch \
libmysql++-dev \
libtool \
libssl-dev \
mysql-client \
grep \
binutils \
zlibc \
libc6 \
libbz2-dev \
cmake \
subversion \
libboost-all-dev


RUN mkdir -p /srv/wow
RUN cd /srv/wow && git clone git://github.com/cmangos/mangos-classic.git && git clone git://github.com/cmangos/classic-db.git
RUN mkdir -p /srv/wow/mangos-classic/build && cd /srv/wow/mangos-classic/build && \
cmake .. -DCMAKE_INSTALL_PREFIX=\../run -DBUILD_EXTRACTORS=ON -DPCH=1 -DDEBUG=0 -DBUILD_PLAYERBOT=ON && \
make && \
make install

EXPOSE 8085 3724


