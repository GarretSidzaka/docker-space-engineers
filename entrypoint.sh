#!/usr/bin/env bash

groupadd --gid 1020 debian
useradd --shell /bin/bash --uid 1020 --gid 1020 --password $(openssl passwd debian) --create-home --home-dir /home/debian debian
usermod -aG sudo debian
/usr/sbin/xrdp-sesman
/usr/sbin/xrdp --nodaemon
